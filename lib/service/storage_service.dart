import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

/// 存储服务类
/// 负责本地数据存储和缓存管理
/// 使用单例模式确保全局唯一实例
class StorageService {
  /// 单例模式实例
  static final StorageService instance = StorageService._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory StorageService() => instance;

  /// 私有构造函数，防止外部实例化
  StorageService._privateConstructor();

  /// 默认缓存管理器，用于文件缓存
  final defaultCacheManager = DefaultCacheManager();

  /// SharedPreferences实例，用于键值对存储
  late final SharedPreferences prefs;

  /// 自定义标签，用于键值对的前缀，避免命名冲突
  // TODO: 修改自定义Tag
  final tag = 'StorageService';

  /// 初始化存储服务
  /// 必须在使用其他方法前调用
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// 获取或设置设备唯一标识符
  String get uniqueDeviceId => (prefs.getString('${tag}uniqueDeviceId') ?? '');
  set uniqueDeviceId(String value) =>
      prefs.setString('${tag}uniqueDeviceId', value);

  /// 获取或设置用户ID
  int get userId => (prefs.getInt('${tag}userId') ?? 0);
  set userId(int value) => prefs.setInt('${tag}userId', value);
}
