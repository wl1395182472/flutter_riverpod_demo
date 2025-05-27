import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;

import '../util/log.dart' show Log;

/// 应用服务类
/// 负责获取应用信息和设备信息
/// 使用单例模式确保全局唯一实例
class AppService {
  /// 单例模式实例
  static final AppService instance = AppService._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory AppService() => instance;

  /// 私有构造函数，防止外部实例化
  AppService._privateConstructor();

  /// 应用名称
  String appName = '';

  /// 构建号
  String buildNumber = '';

  /// 构建签名
  String buildSignature = '';

  /// 安装时间
  DateTime? installTime;

  /// 安装来源商店
  String? installerStore;

  /// 包名
  String packageName = '';

  /// 更新时间
  DateTime? updateTime;

  /// 版本号
  String version = '';

  /// 设备信息插件实例
  final deviceInfo = DeviceInfoPlugin();

  /// 初始化应用服务
  /// 并行获取应用包信息和设备信息
  Future<void> init() async {
    await Future.wait([
      getPackageInfo(),
      getDeviceInfo(),
    ]);
  }

  /// 获取应用包信息
  /// 包括应用名称、版本号、构建号等基本信息
  Future<void> getPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appName = packageInfo.appName;
      buildNumber = packageInfo.buildNumber;
      buildSignature = packageInfo.buildSignature;
      installTime = packageInfo.installTime;
      installerStore = packageInfo.installerStore;
      packageName = packageInfo.packageName;
      updateTime = packageInfo.updateTime;
      version = packageInfo.version;
    } catch (error, stackTrace) {
      Log.instance.logger.e(
        '[AppService]getPackageInfo error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 获取设备信息
  /// 根据不同平台获取相应的设备详细信息
  Future<void> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        // Web平台：获取浏览器信息
        final webInfo = await deviceInfo.webBrowserInfo;
        Log.instance.logger.i(
          '[AppService]Web Browser Info: ${webInfo.userAgent}',
        );
      } else if (Platform.isAndroid) {
        // Android平台：获取设备型号和系统版本
        final androidInfo = await deviceInfo.androidInfo;
        Log.instance.logger.i(
          '[AppService]Android Device Info: ${androidInfo.model}, ${androidInfo.version.release}',
        );
      } else if (Platform.isIOS) {
        // iOS平台：获取设备型号和系统版本
        final iosInfo = await deviceInfo.iosInfo;
        Log.instance.logger.i(
          '[AppService]iOS Device Info: ${iosInfo.model}, ${iosInfo.systemVersion}',
        );
      } else {
        // 其他平台：获取通用设备信息
        final otherInfo = await deviceInfo.deviceInfo;
        Log.instance.logger.i(
          '[AppService]Other Device Info: ${otherInfo.toString()}',
        );
      }
    } catch (error, stackTrace) {
      Log.instance.logger.e(
        '[AppService]getDeviceInfo error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
