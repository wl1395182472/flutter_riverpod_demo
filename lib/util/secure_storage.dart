import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // 单例实例
  static final SecureStorage instance = SecureStorage._internal();

  // 私有构造函数
  SecureStorage._internal();

  // 实际使用的底层存储实例
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
