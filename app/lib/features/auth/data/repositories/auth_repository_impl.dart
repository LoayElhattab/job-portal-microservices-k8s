import '../../../../core/network/auth_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthStorage authStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.authStorage);

  @override
  Future<User> login(String email, String password) async {
    final data = await remoteDataSource.login(email, password);

    await authStorage.saveToken(data['token']);

    return UserModel.fromJson(data['user']);
  }

  @override
  Future<User> register(String email, String password, String role) async {
    final data = await remoteDataSource.register(email, password, role);
    await authStorage.saveToken(data['token']);
    return UserModel.fromJson(data['user']);
  }

  @override
  Future<void> logout() async {
    await authStorage.deleteToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await authStorage.getToken();
    if (token == null) return null;

    return User(id: '0', email: 'cached@user.com', role: 'unknown');
  }
}
