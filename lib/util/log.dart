import 'package:logger/logger.dart' show Logger;

/// 日志工具类
///
/// 基于 logger 包的单例日志管理工具，提供统一的日志输出功能
/// 使用单例模式确保整个应用共享同一个日志实例
///
/// 使用示例：
/// ```dart
/// Log.instance.logger.d('Debug message');
/// Log.instance.logger.i('Info message');
/// Log.instance.logger.w('Warning message');
/// Log.instance.logger.e('Error message');
/// ```
class Log {
  /// 私有构造函数，防止外部直接实例化
  Log._privateConstructor();

  /// 单例实例
  static final instance = Log._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory Log() {
    return instance;
  }

  /// Logger实例，用于实际的日志输出
  /// 支持不同级别的日志：trace, debug, info, warning, error, wtf
  final logger = Logger();
}
