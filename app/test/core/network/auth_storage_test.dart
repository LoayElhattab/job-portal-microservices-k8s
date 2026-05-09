import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jobportal_app/core/network/auth_storage.dart';
import '../../helpers/mock_helper.mocks.dart';

void main() {
  late AuthStorage authStorage;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    authStorage = AuthStorage(storage: mockSecureStorage);
  });

  const tToken = 'test-token';

  test('should save token using secure storage', () async {
    // arrange
    when(mockSecureStorage.write(key: 'jwt_token', value: tToken))
        .thenAnswer((_) async {});

    // act
    await authStorage.saveToken(tToken);

    // assert
    verify(mockSecureStorage.write(key: 'jwt_token', value: tToken)).called(1);
  });

  test('should get token from secure storage', () async {
    // arrange
    when(mockSecureStorage.read(key: 'jwt_token'))
        .thenAnswer((_) async => tToken);

    // act
    final result = await authStorage.getToken();

    // assert
    expect(result, tToken);
    verify(mockSecureStorage.read(key: 'jwt_token')).called(1);
  });

  test('should delete token from secure storage', () async {
    // arrange
    when(mockSecureStorage.delete(key: 'jwt_token'))
        .thenAnswer((_) async {});

    // act
    await authStorage.deleteToken();

    // assert
    verify(mockSecureStorage.delete(key: 'jwt_token')).called(1);
  });
}
