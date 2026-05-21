import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'jwt_token';

  AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async =>
      await _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<void> deleteToken() async => await _storage.delete(key: _tokenKey);
}
