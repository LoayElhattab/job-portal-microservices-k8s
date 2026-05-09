import '../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.dio.post(
      '/users/login',
      data: {'email': email, 'password': password},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String role,
  ) async {
    final response = await apiClient.dio.post(
      '/users/register',
      data: {'email': email, 'password': password, 'role': role},
    );
    return response.data['data'];
  }
}
