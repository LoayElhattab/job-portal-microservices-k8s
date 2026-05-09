import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:jobportal_app/core/network/api_interceptor.dart';
import 'package:jobportal_app/core/network/auth_storage.dart';

class MockAuthStorage extends Mock implements AuthStorage {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late ApiInterceptor apiInterceptor;
  late MockAuthStorage mockAuthStorage;

  setUp(() {
    mockAuthStorage = MockAuthStorage();
    apiInterceptor = ApiInterceptor(mockAuthStorage);
  });

  test('should add Authorization header if token exists', () async {
    // arrange
    const tToken = 'test-token';
    when(mockAuthStorage.getToken()).thenAnswer((_) async => tToken);
    final options = RequestOptions(path: '/test');
    final handler = MockRequestInterceptorHandler();

    // act
    apiInterceptor.onRequest(options, handler);

    // assert
    // Since onRequest is async, we might need a small delay or use a fake handler
    // Actually, in Dio Interceptor, the call to super.onRequest is synchronous after the await.
    // However, the onRequest method itself is marked async in our lib.
    
    // We can wait for the event loop
    await Future.delayed(Duration.zero);
    
    expect(options.headers['Authorization'], 'Bearer $tToken');
    verify(handler.next(options)).called(1);
  });

  test('should not add Authorization header if token is null', () async {
    // arrange
    when(mockAuthStorage.getToken()).thenAnswer((_) async => null);
    final options = RequestOptions(path: '/test');
    final handler = MockRequestInterceptorHandler();

    // act
    apiInterceptor.onRequest(options, handler);
    await Future.delayed(Duration.zero);

    // assert
    expect(options.headers.containsKey('Authorization'), false);
    verify(handler.next(options)).called(1);
  });

  test('should pass error to next handler', () async {
    // arrange
    final dioException = DioException(requestOptions: RequestOptions(path: '/test'));
    final handler = MockErrorInterceptorHandler();

    // act
    apiInterceptor.onError(dioException, handler);

    // assert
    verify(handler.next(dioException)).called(1);
  });
}
