import 'package:dio/dio.dart';

import 'auth_storage.dart';

class ApiInterceptor extends Interceptor {
  final AuthStorage authStorage;

  ApiInterceptor(this.authStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await authStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Handle global logout / redirect to login screen via GoRouter
      print('🔥 Unauthorized! Token expired or invalid.');
    }
    super.onError(err, handler);
  }
}
