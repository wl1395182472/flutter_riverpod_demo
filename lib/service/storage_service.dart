import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  /// 单例模式
  static final StorageService instance = StorageService._privateConstructor();
  factory StorageService() => instance;
  StorageService._privateConstructor();

  final defaultCacheManager = DefaultCacheManager();

  late final SharedPreferences prefs;

  // TODO: 修改自定义Tag
  final tag = 'StorageService';

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  String get uniqueDeviceId => (prefs.getString('${tag}uniqueDeviceId') ?? '');
  set uniqueDeviceId(String value) =>
      prefs.setString('${tag}uniqueDeviceId', value);

  int get userId => (prefs.getInt('${tag}userId') ?? 0);
  set userId(int value) => prefs.setInt('${tag}userId', value);
}
