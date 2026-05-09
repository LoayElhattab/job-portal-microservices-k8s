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
    authStorage = AuthStorage();
  });

  const tToken = 'test-token';

  test('should complete saving token', () async {
    await authStorage.saveToken(tToken);
  });

  test('should complete getting token', () async {
    await authStorage.getToken();
  });

  test('should complete deleting token', () async {
    await authStorage.deleteToken();
  });
}
