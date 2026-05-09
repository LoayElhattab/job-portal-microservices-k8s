import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import 'api_interceptor.dart';
import 'auth_storage.dart';

class ApiClient {
  late final Dio dio;

  ApiClient(AuthStorage authStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig().baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(ApiInterceptor(authStorage));
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
}
