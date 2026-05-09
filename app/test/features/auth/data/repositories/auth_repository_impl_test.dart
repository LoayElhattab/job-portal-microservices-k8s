import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jobportal_app/features/auth/domain/entities/user.dart';
import '../../../../helpers/mock_helper.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthStorage mockAuthStorage;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockAuthStorage = MockAuthStorage();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockAuthStorage);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tToken = 'test-token';
  const tUserData = {'id': 1, 'email': tEmail, 'role': 'seeker'};

  group('login', () {
    test('should call remote datasource and save token on success', () async {
      // arrange
      when(mockRemoteDataSource.login(tEmail, tPassword)).thenAnswer((_) async => {
            'token': tToken,
            'user': tUserData,
          });
      when(mockAuthStorage.saveToken(tToken)).thenAnswer((_) async => null);

      // act
      final result = await repository.login(tEmail, tPassword);

      // assert
      expect(result, isA<User>());
      expect(result.email, tEmail);
      verify(mockRemoteDataSource.login(tEmail, tPassword));
      verify(mockAuthStorage.saveToken(tToken));
    });

    test('should throw exception when remote datasource fails', () async {
      // arrange
      when(mockRemoteDataSource.login(tEmail, tPassword)).thenThrow(Exception('Server Error'));

      // act
      final call = repository.login;

      // assert
      expect(() => call(tEmail, tPassword), throwsA(isA<Exception>()));
    });
  });

  group('logout', () {
    test('should call deleteToken on auth storage', () async {
      // arrange
      when(mockAuthStorage.deleteToken()).thenAnswer((_) async => null);

      // act
      await repository.logout();

      // assert
      verify(mockAuthStorage.deleteToken());
    });
  });
}
