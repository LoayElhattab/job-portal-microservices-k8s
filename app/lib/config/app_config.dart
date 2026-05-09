class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  String baseUrl = 'http://localhost:3100/api/v1';
  String environment = 'development';
}