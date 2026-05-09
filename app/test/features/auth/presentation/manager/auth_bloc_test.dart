import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/features/auth/domain/entities/user.dart';
import 'package:jobportal_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:jobportal_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jobportal_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_bloc.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_event.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tUser = User(id: 1, email: 'test@example.com', role: 'seeker');

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockLoginUseCase(any, any)).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test@example.com', password: 'password')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUseCase(any, any)).thenThrow(Exception('Login failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test@example.com', password: 'password')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  group('RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when registration is successful',
      build: () {
        when(mockRegisterUseCase(any, any, any)).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterRequested(email: 'test@example.com', password: 'password', role: 'seeker')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when registration fails',
      build: () {
        when(mockRegisterUseCase(any, any, any)).thenThrow(Exception('Registration failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterRequested(email: 'test@example.com', password: 'password', role: 'seeker')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout is called',
      build: () {
        when(mockLogoutUseCase()).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });
}
