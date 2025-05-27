/// 应用配置类
/// 使用单例模式管理应用程序的配置信息
/// 包含登录配置、产品ID等重要配置项
class AppConfig {
  /// 私有构造函数，防止外部直接实例化
  AppConfig._privateConstructor();

  /// 单例实例
  static final instance = AppConfig._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory AppConfig() {
    return instance;
  }

  /// TODO: 应用程序名称
  final appName = 'MyApp';

  /// TODO: Apple登录在Android平台的客户端ID
  final appleLoginOnAndroidClientId = '';

  /// TODO: Apple登录在Android平台的重定向URI
  final appleLoginOnAndroidRedirectUri = '';

  /// TODO: Android Web服务器客户端ID
  final androidWebServerClientId = '';

  /// TODO: 700代币产品ID
  final token700ProductId = '';

  /// TODO: 5000代币产品ID
  final token5000ProductId = '';

  /// TODO: Pro版本月度订阅产品ID
  final proMonthlyProductId = '';

  /// TODO: Pro版本年度订阅产品ID
  final proYearlyProductId = '';

  /// TODO: Pro Plus版本月度订阅产品ID
  final proPlusMonthlyProductId = '';

  /// TODO: Pro Plus版本年度订阅产品ID
  final proPlusYearlyProductId = '';
}
