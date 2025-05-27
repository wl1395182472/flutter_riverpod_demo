import 'dart:convert' show utf8, jsonDecode;
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:dio/dio.dart'
    show
        Dio,
        BaseOptions,
        Options,
        CancelToken,
        ProgressCallback,
        Response,
        DioException,
        ResponseBody,
        LogInterceptor,
        FormData,
        MultipartFile,
        ResponseType,
        DioExceptionType;
import 'package:flutter/foundation.dart' show kDebugMode;

import '../model/http_method.dart' show HttpMethod;
import '../util/log.dart' show Log;

/// HTTP服务类，封装dio插件实现网络请求
/// 提供GET、POST、文件上传下载、SSE连接等功能
/// 使用单例模式确保全局唯一实例
class HttpService {
  /// 单例模式实例
  static final HttpService instance = HttpService._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory HttpService() => instance;

  /// 私有构造函数，防止外部实例化
  HttpService._privateConstructor();

  /// dio实例，用于发起HTTP请求
  late final Dio _dio = _createDio();

  /// 创建dio实例并配置基础设置和拦截器
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '', // 根据实际环境配置基础URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加日志拦截器，用于调试网络请求
    dio.interceptors.add(LogInterceptor(
      request: true, // 记录请求信息
      requestHeader: true, // 记录请求头
      requestBody: true, // 记录请求体
      responseHeader: true, // 记录响应头
      responseBody: true, // 记录响应体
      error: true, // 记录错误信息
      logPrint: (object) {
        if (kDebugMode) {
          Log().logger.d(object.toString());
        }
      },
    ));

    return dio;
  }

  /// 基础请求方法
  /// [url] 请求地址
  /// [method] 请求方法
  /// [queryParameters] 查询参数
  /// [data] 请求体数据
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  /// [onSendProgress] 上传进度回调
  /// [onReceiveProgress] 下载进度回调
  Future<dynamic> request({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response;
      options ??= Options();
      options.method = method.name.toUpperCase();

      response = await _dio.request(
        url,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      Log().logger.e('网络请求异常: $e');
      throw Exception('网络请求异常: $e');
    }
  }

  /// GET请求
  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      url: url,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST请求
  Future<dynamic> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      url: url,
      method: HttpMethod.post,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 文件上传
  Future<dynamic> upload(
    String url, {
    required File file,
    required String fileName,
    String? fileKey,
    Map<String, dynamic>? extraData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();

      // 添加文件
      final fileUpload = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      );
      formData.files.add(MapEntry(fileKey ?? 'file', fileUpload));

      // 添加额外数据
      if (extraData != null) {
        extraData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      return post(
        url,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      Log().logger.e('文件上传失败: $e');
      throw Exception('文件上传失败: $e');
    }
  }

  /// 多文件上传
  Future<dynamic> uploadMultiple(
    String url, {
    required List<File> files,
    required List<String> fileNames,
    String? fileKey,
    Map<String, dynamic>? extraData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();

      // 添加文件
      for (int i = 0; i < files.length; i++) {
        final fileUpload = await MultipartFile.fromFile(
          files[i].path,
          filename: fileNames[i],
        );
        formData.files.add(MapEntry(fileKey ?? 'files', fileUpload));
      }

      // 添加额外数据
      if (extraData != null) {
        extraData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      return post(
        url,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      Log().logger.e('多文件上传失败: $e');
      throw Exception('多文件上传失败: $e');
    }
  }

  /// 下载文件
  Future<dynamic> download(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool deleteIfExists = true,
  }) async {
    try {
      final saveFile = File(savePath);
      if (deleteIfExists && await saveFile.exists()) {
        await saveFile.delete();
      }

      Response response = await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } catch (e) {
      Log().logger.e('文件下载失败: $e');
      throw Exception('文件下载失败: $e');
    }
  }

  /// 流式请求，用于处理大量数据
  Future<Stream<Uint8List>> stream(
    String url, {
    HttpMethod method = HttpMethod.get,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      options ??= Options();
      options.method = method.name.toUpperCase();
      options.responseType = ResponseType.stream;

      final Response<ResponseBody> response = await _dio.request<ResponseBody>(
        url,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );

      return response.data!.stream;
    } catch (e) {
      Log().logger.e('流式请求失败: $e');
      throw Exception('流式请求失败: $e');
    }
  }

  /// SSE连接（Server-Sent Events）
  Stream<dynamic> connectSSE(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async* {
    try {
      // 添加SSE专用头
      final options = Options(
        headers: {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
          if (headers != null) ...headers,
        },
        responseType: ResponseType.stream,
      );

      // 发起SSE连接
      final Response<ResponseBody> response = await _dio.get<ResponseBody>(
        url,
        queryParameters: queryParameters,
        options: options,
      );

      // 处理SSE事件流
      final Stream<Uint8List> stream = response.data!.stream;
      String buffer = '';

      await for (final Uint8List chunk in stream) {
        final String chunkString = utf8.decode(chunk);
        buffer += chunkString;

        // 处理可能的多行事件
        while (buffer.contains('\n\n')) {
          final int index = buffer.indexOf('\n\n');
          final String eventData = buffer.substring(0, index);
          buffer = buffer.substring(index + 2);

          // 解析事件数据
          if (eventData.isNotEmpty) {
            final Map<String, dynamic> parsedEvent = _parseSSEEvent(eventData);
            if (parsedEvent.containsKey('data')) {
              yield parsedEvent['data'];
            }
          }
        }
      }
    } catch (e) {
      Log().logger.e('SSE连接失败: $e');
      throw Exception('SSE连接失败: $e');
    }
  }

  /// 解析SSE事件
  Map<String, dynamic> _parseSSEEvent(String eventString) {
    final Map<String, dynamic> result = {};
    final List<String> lines = eventString.split('\n');

    for (final String line in lines) {
      if (line.isEmpty) continue;

      if (line.startsWith('data:')) {
        final String data = line.substring(5).trim();
        // 尝试解析JSON，如果不是JSON则保持原始字符串
        try {
          result['data'] = jsonDecode(data);
        } catch (_) {
          result['data'] = data;
        }
      } else if (line.startsWith('event:')) {
        result['event'] = line.substring(6).trim();
      } else if (line.startsWith('id:')) {
        result['id'] = line.substring(3).trim();
      } else if (line.startsWith('retry:')) {
        result['retry'] = int.tryParse(line.substring(6).trim());
      }
    }

    return result;
  }

  /// 处理Dio异常
  void _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        Log().logger.e('连接超时');
        throw Exception('连接超时');
      case DioExceptionType.sendTimeout:
        Log().logger.e('请求超时');
        throw Exception('请求超时');
      case DioExceptionType.receiveTimeout:
        Log().logger.e('响应超时');
        throw Exception('响应超时');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        Log().logger.e('服务器错误 [$statusCode]: $responseData');
        throw Exception('服务器错误 [$statusCode]');
      case DioExceptionType.cancel:
        Log().logger.e('请求取消');
        throw Exception('请求取消');
      case DioExceptionType.connectionError:
        Log().logger.e('网络连接错误');
        throw Exception('网络连接错误');
      default:
        Log().logger.e('网络请求错误: ${e.message}');
        throw Exception('网络请求错误: ${e.message}');
    }
  }
}
