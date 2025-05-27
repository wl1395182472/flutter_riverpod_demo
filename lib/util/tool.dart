import 'dart:convert' show utf8;
import 'dart:io' show Platform;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show Rect;

import 'package:app_tracking_transparency/app_tracking_transparency.dart'
    show TrackingStatus, AppTrackingTransparency;
import 'package:crypto/crypto.dart' show sha256, md5;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart' show NumberFormat;
import 'package:mime/mime.dart' show lookupMimeType;
import 'package:mobile_device_identifier/mobile_device_identifier.dart'
    show MobileDeviceIdentifier;
import 'package:share_plus/share_plus.dart'
    show XFile, SharePlus, ShareParams, ShareResultStatus;
import 'package:url_launcher/url_launcher_string.dart'
    show canLaunchUrlString, launchUrlString;
import 'package:uuid/uuid.dart' show Uuid;

import '../service/storage_service.dart' show StorageService;
import 'log.dart' show Log;
import 'toast.dart' show Toast;

/// 工具类
///
/// 提供应用中常用的工具方法和功能
/// - 加密算法（SHA256、MD5）
/// - UUID生成
/// - URL启动
/// - 数字格式化
/// - 设备ID获取
/// - 分享功能
/// - MIME类型判断
///
/// 使用单例模式，确保全局唯一实例
class Tool {
  /// 私有构造函数，防止外部直接实例化
  Tool._privateConstructor();

  /// 单例实例
  static final instance = Tool._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory Tool() {
    return instance;
  }

  /// SHA256 加密
  ///
  /// [input] 需要加密的字符串
  /// 返回SHA256加密后的字符串
  String generateSHA256(String input) {
    // 将字符串转换为字节数组
    final bytes = utf8.encode(input);
    // 使用sha256加密
    final digest = sha256.convert(bytes);
    // 将Digest对象转换为字符串
    return digest.toString();
  }

  /// 生成MD5哈希值
  /// [input] - 需要进行MD5加密的字符串
  /// 返回32位小写MD5哈希字符串
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  /// UUID生成器实例
  static const uuid = Uuid();

  /// 生成UUID
  /// 返回一个随机的UUID v4字符串
  static String getUuid() {
    return uuid.v4();
  }

  /// 启动外部URL
  ///
  /// [url] 要启动的URL地址
  /// 支持网页链接、深度链接等各种URL类型
  Future<void> launchUrl(String url) async {
    try {
      final canLaunch = await canLaunchUrlString(url);
      if (canLaunch) {
        await launchUrlString(url);
      } else {
        Toast.show('Unable to launch URL: $url');
      }
    } catch (error, stackTrace) {
      Toast.show('Failed to launch URL: $url');
      Log.instance.logger.e(
        '[Tool]launchUrl error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 将数字转换为简化显示格式
  ///
  /// [value] 要格式化的数字
  /// 返回格式化后的字符串，如：1000 -> 1K, 1000000 -> 1M
  String toCountText(int value) {
    return NumberFormat.compact().format(value);
  }

  /// iOS广告跟踪权限状态
  TrackingStatus? appTrackingTransparencyStatus;

  /// 获取设备唯一标识符
  /// 返回MD5加密后的设备ID或UUID
  Future<String> fetchDeviceId() async {
    if (StorageService.instance.uniqueDeviceId.isEmpty) {
      if (kIsWeb) {
        // Web平台处理（此处可以添加Web端的唯一标识获取逻辑）
      } else if (Platform.isIOS) {
        // 获取iOS广告追踪授权状态
        appTrackingTransparencyStatus =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        while (appTrackingTransparencyStatus == TrackingStatus.notDetermined) {
          appTrackingTransparencyStatus =
              await AppTrackingTransparency.requestTrackingAuthorization();
          await Future.delayed(Duration(milliseconds: 1000));
        }
      }
      final mobileDeviceIdentifier =
          await MobileDeviceIdentifier().getDeviceId();
      StorageService.instance.uniqueDeviceId = mobileDeviceIdentifier != null
          ? generateMd5(mobileDeviceIdentifier)
          : getUuid();
    }
    // 确保设备ID不为空或默认值
    if (StorageService.instance.uniqueDeviceId.isEmpty ||
        StorageService.instance.uniqueDeviceId ==
            '00000000-0000-0000-0000-000000000000') {
      StorageService.instance.uniqueDeviceId = getUuid();
    }
    return StorageService.instance.uniqueDeviceId;
  }

  /// 分享内容
  ///
  /// [text] 要分享的文本内容，不能与 [uri] 同时使用
  /// [subject] 邮件主题，用于邮件分享场景
  /// [title] 分享标题，在分享弹窗中显示
  /// [previewThumbnail] 预览缩略图，仅 Android 平台支持
  /// [sharePositionOrigin] iPad 和 Mac 上分享弹窗的位置
  /// [uri] 要分享的链接，iOS 会获取网页图标显示，不能与 [text] 同时使用
  /// [files] 要分享的文件列表，支持多种 MIME 类型
  /// [fileNameOverrides] 覆盖文件名，长度必须与 [files] 列表一致
  /// [downloadFallbackEnabled] Web 平台分享失败时是否启用下载回退
  /// [mailToFallbackEnabled] Web 平台分享失败时是否启用邮件回退
  ///
  /// 返回值：分享是否成功
  ///
  /// 支持的平台：
  /// - 文本/链接分享：所有平台
  /// - 文件分享：Android, iOS, Web, macOS, Windows
  /// - 预览缩略图：仅 Android
  /// - 分享位置：仅 iPad 和 Mac
  Future<bool> share({
    String? text,
    String? subject,
    String? title,
    XFile? previewThumbnail,
    Rect? sharePositionOrigin,
    Uri? uri,
    List<XFile>? files,
    List<String>? fileNameOverrides,
    bool downloadFallbackEnabled = true,
    bool mailToFallbackEnabled = true,
  }) async {
    bool result = false;
    try {
      // 验证参数
      if (text != null && uri != null) {
        throw ArgumentError('text 和 uri 参数不能同时使用');
      }

      if (fileNameOverrides != null && files != null) {
        if (fileNameOverrides.length != files.length) {
          throw ArgumentError('fileNameOverrides 长度必须与 files 列表长度一致');
        }
      }

      // 执行分享
      final shareResult = await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          title: title,
          previewThumbnail: previewThumbnail,
          sharePositionOrigin: sharePositionOrigin,
          uri: uri,
          files: files,
          fileNameOverrides: fileNameOverrides,
          downloadFallbackEnabled: downloadFallbackEnabled,
          mailToFallbackEnabled: mailToFallbackEnabled,
        ),
      );

      // 判断分享结果
      result = shareResult.status == ShareResultStatus.success;

      // 记录分享结果
      Log.instance.logger.i(
        '[Tool]share result: ${shareResult.status.name}, raw: ${shareResult.raw}',
      );
    } catch (error, stackTrace) {
      Toast.show('分享失败');
      Log.instance.logger.e(
        '[Tool]share error',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 分享文本内容
  ///
  /// [text] 要分享的文本内容
  /// [title] 分享标题（可选）
  /// [subject] 邮件主题（可选）
  Future<bool> shareText(String text, {String? title, String? subject}) async {
    return share(text: text, title: title, subject: subject);
  }

  /// 分享链接
  ///
  /// [uri] 要分享的链接
  /// [title] 分享标题（可选）
  /// [subject] 邮件主题（可选）
  Future<bool> shareLink(Uri uri, {String? title, String? subject}) async {
    return share(uri: uri, title: title, subject: subject);
  }

  /// 分享单个文件
  ///
  /// [file] 要分享的文件
  /// [fileName] 自定义文件名（可选）
  /// [title] 分享标题（可选）
  /// [text] 附加文本内容（可选）
  Future<bool> shareFile(
    XFile file, {
    String? fileName,
    String? title,
    String? text,
  }) async {
    return share(
      files: [file],
      fileNameOverrides: fileName != null ? [fileName] : null,
      title: title,
      text: text,
    );
  }

  /// 分享多个文件
  ///
  /// [files] 要分享的文件列表
  /// [fileNames] 自定义文件名列表（可选，长度必须与files一致）
  /// [title] 分享标题（可选）
  /// [text] 附加文本内容（可选）
  Future<bool> shareFiles(
    List<XFile> files, {
    List<String>? fileNames,
    String? title,
    String? text,
  }) async {
    // 验证文件名列表长度
    if (fileNames != null && fileNames.length != files.length) {
      throw ArgumentError('fileNames 长度必须与 files 列表长度一致');
    }

    return share(
      files: files,
      fileNameOverrides: fileNames,
      title: title,
      text: text,
    );
  }

  /// 从文件路径创建XFile
  ///
  /// [filePath] 文件路径
  /// [mimeType] MIME类型（可选，会自动推断）
  /// [name] 文件名（可选，会从路径提取）
  XFile createXFile(String filePath, {String? mimeType, String? name}) {
    return XFile(
      filePath,
      mimeType: mimeType ?? getMimeType(filePath),
      name: name,
    );
  }

  /// 从字节数据创建XFile
  ///
  /// [bytes] 文件字节数据
  /// [name] 文件名
  /// [mimeType] MIME类型（可选，会自动推断）
  XFile createXFileFromBytes(
    Uint8List bytes,
    String name, {
    String? mimeType,
  }) {
    return XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType ?? getMimeType(name),
    );
  }

  /// 获取文件的MIME类型
  ///
  /// [filePath] 文件路径或文件名
  /// 返回MIME类型字符串，如果无法识别则返回null
  String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  /// 根据字节数据获取MIME类型
  ///
  /// [bytes] 文件字节数据
  /// [filePath] 文件路径（可选，用于辅助判断）
  /// 返回MIME类型字符串，如果无法识别则返回null
  String? getMimeTypeFromBytes(Uint8List bytes, {String? filePath}) {
    return lookupMimeType(filePath ?? '', headerBytes: bytes);
  }

  /// 验证文件是否为指定的MIME类型
  ///
  /// [filePath] 文件路径
  /// [expectedMimeType] 期望的MIME类型
  /// 返回是否匹配
  bool isMimeType(String filePath, String expectedMimeType) {
    final mimeType = getMimeType(filePath);
    return mimeType == expectedMimeType;
  }

  /// 验证文件是否为图片类型
  ///
  /// [filePath] 文件路径
  /// 返回是否为图片
  bool isImageFile(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('image/') ?? false;
  }

  /// 验证文件是否为视频类型
  ///
  /// [filePath] 文件路径
  /// 返回是否为视频
  bool isVideoFile(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('video/') ?? false;
  }

  /// 验证文件是否为音频类型
  ///
  /// [filePath] 文件路径
  /// 返回是否为音频
  bool isAudioFile(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('audio/') ?? false;
  }

  /// 验证文件是否为文本类型
  ///
  /// [filePath] 文件路径
  /// 返回是否为文本
  bool isTextFile(String filePath) {
    final mimeType = getMimeType(filePath);
    return mimeType?.startsWith('text/') ?? false;
  }

  /// 获取文件扩展名对应的MIME类型
  ///
  /// [extension] 文件扩展名（如 '.jpg', 'png'）
  /// 返回MIME类型字符串
  String? getMimeTypeByExtension(String extension) {
    // 确保扩展名以点开头
    final ext = extension.startsWith('.') ? extension : '.$extension';
    return lookupMimeType('file$ext');
  }
}
