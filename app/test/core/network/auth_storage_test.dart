import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jobportal_app/core/network/auth_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthStorage authStorage;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    authStorage = AuthStorage(mockSecureStorage);
  });

  const tToken = 'test-token';

  test('should call write on secure storage when saving token', () async {
    // act
    await authStorage.saveToken(tToken);
    // assert
    verify(mockSecureStorage.write(key: 'jwt_token', value: tToken));
  });

  test('should call read on secure storage when getting token', () async {
    // arrange
    when(mockSecureStorage.read(key: 'jwt_token'))
        .thenAnswer((_) async => tToken);
    // act
    final result = await authStorage.getToken();
    // assert
    expect(result, tToken);
    verify(mockSecureStorage.read(key: 'jwt_token'));
  });

  test('should call delete on secure storage when deleting token', () async {
    // act
    await authStorage.deleteToken();
    // assert
    verify(mockSecureStorage.delete(key: 'jwt_token'));
  });
}
