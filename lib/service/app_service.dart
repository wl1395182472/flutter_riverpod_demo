import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../util/log.dart';

class AppService {
  /// 单例模式
  static final AppService instance = AppService._privateConstructor();
  factory AppService() => instance;
  AppService._privateConstructor();

  String appName = '';
  String buildNumber = '';
  String buildSignature = '';
  DateTime? installTime;
  String? installerStore;
  String packageName = '';
  DateTime? updateTime;
  String version = '';

  final deviceInfo = DeviceInfoPlugin();

  Future<void> init() async {
    await Future.wait([
      getPackageInfo(),
      getDeviceInfo(),
    ]);
  }

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

  Future<void> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        Log.instance.logger.i(
          '[AppService]Web Browser Info: ${webInfo.userAgent}',
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        Log.instance.logger.i(
          '[AppService]Android Device Info: ${androidInfo.model}, ${androidInfo.version.release}',
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        Log.instance.logger.i(
          '[AppService]iOS Device Info: ${iosInfo.model}, ${iosInfo.systemVersion}',
        );
      } else {
        final otherInfo = await deviceInfo.deviceInfo;
        Log.instance.logger.i(
          '[AppService]Other Device Info: ${otherInfo.toString()}',
        );
      }
    } catch (error, stackTrace) {
      Log.instance.logger.e(
        '[AppService]getPackageInfo error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
