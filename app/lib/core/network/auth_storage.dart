import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async =>
      await _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<void> deleteToken() async => await _storage.delete(key: _tokenKey);
}
