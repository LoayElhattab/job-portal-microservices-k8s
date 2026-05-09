import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/core/network/api_client.dart';
import 'package:jobportal_app/features/auth/data/datasources/auth_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late AuthRemoteDataSource dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    // In our implementation, ApiClient exposes 'dio' property.
    // We need to mock that property.
    when(mockApiClient.dio).thenReturn(mockDio);
    dataSource = AuthRemoteDataSource(mockApiClient);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tRole = 'seeker';

  group('login', () {
    test('should return map of data when status is 200', () async {
      // arrange
      final tResponseData = {
        'success': true,
        'data': {
          'token': 'test-token',
          'user': {'id': 1, 'email': tEmail, 'role': tRole}
        }
      };
      
      when(mockDio.post(
        '/users/login',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      final result = await dataSource.login(tEmail, tPassword);

      // assert
      expect(result, tResponseData['data']);
      verify(mockDio.post(
        '/users/login',
        data: {'email': tEmail, 'password': tPassword},
      ));
    });

    test('should throw DioException when status is not 200', () async {
      // arrange
      when(mockDio.post(
        '/users/login',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // act
      final call = dataSource.login;

      // assert
      expect(() => call(tEmail, tPassword), throwsA(isA<DioException>()));
    });
  });

  group('register', () {
    test('should return map of data when status is 201', () async {
      // arrange
      final tResponseData = {
        'success': true,
        'data': {
          'token': 'test-token',
          'user': {'id': 1, 'email': tEmail, 'role': tRole}
        }
      };
      
      when(mockDio.post(
        '/users/register',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      final result = await dataSource.register(tEmail, tPassword, tRole);

      // assert
      expect(result, tResponseData['data']);
      verify(mockDio.post(
        '/users/register',
        data: {'email': tEmail, 'password': tPassword, 'role': tRole},
      ));
    });
  });
}
