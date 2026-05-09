import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:jobportal_app/core/network/api_interceptor.dart';
import '../../helpers/mock_helper.mocks.dart';

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

    // Wait for the async getToken call to complete
    await Future.delayed(Duration.zero);

    // assert
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
