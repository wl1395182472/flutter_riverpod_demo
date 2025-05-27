import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage, AndroidOptions;

/// 安全存储工具类
///
/// 基于 flutter_secure_storage 包的单例安全存储管理工具
/// 使用单例模式确保整个应用共享同一个存储实例
///
/// 功能特性：
/// - 在Android上启用加密的SharedPreferences
/// - 提供键值对的安全存储、读取、删除功能
/// - 支持清空所有存储数据
///
/// 使用示例：
/// ```dart
/// // 存储数据
/// await SecureStorage.instance.write(key: 'token', value: 'user_token');
///
/// // 读取数据
/// final token = await SecureStorage.instance.read(key: 'token');
///
/// // 删除数据
/// await SecureStorage.instance.delete(key: 'token');
///
/// // 清空所有数据
/// await SecureStorage.instance.deleteAll();
/// ```
class SecureStorage {
  /// 单例实例
  static final SecureStorage instance = SecureStorage._internal();

  /// 私有构造函数，防止外部直接实例化
  SecureStorage._internal();

  /// 实际使用的底层存储实例
  /// 在Android平台启用加密的SharedPreferences以提高安全性
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// 向安全存储写入数据
  ///
  /// [key] 存储键
  /// [value] 要存储的值
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// 从安全存储读取数据
  ///
  /// [key] 存储键
  /// 返回存储的值，如果不存在返回null
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// 删除安全存储中的指定数据
  ///
  /// [key] 要删除的键
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// 清除所有安全存储的数据
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
