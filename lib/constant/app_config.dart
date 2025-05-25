class AppConfig {
  AppConfig._privateConstructor();

  static final instance = AppConfig._privateConstructor();

  factory AppConfig() {
    return instance;
  }

  final appName = 'MyApp';

  final appleLoginOnAndroidClientId = '';

  final appleLoginOnAndroidRedirectUri = '';

  final androidWebServerClientId = '';

  final token700ProductId = '';
  final token5000ProductId = '';

  final proMonthlyProductId = '';
  final proYearlyProductId = '';
  final proPlusMonthlyProductId = '';
  final proPlusYearlyProductId = '';
}
