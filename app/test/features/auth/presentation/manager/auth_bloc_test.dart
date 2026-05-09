import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/features/auth/domain/entities/user.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_bloc.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_event.dart';
import 'package:jobportal_app/features/auth/presentation/manager/auth_state.dart';
import '../../../../helpers/mock_helper.mocks.dart';

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

  final tUser = User(id: 1, email: 'test@example.com', role: 'seeker');

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockLoginUseCase('test@example.com', 'password'))
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested('test@example.com', 'password')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUseCase('test@example.com', 'password'))
            .thenThrow(Exception('Login failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested('test@example.com', 'password')),
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
        when(mockRegisterUseCase('test@example.com', 'password', 'seeker'))
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested('test@example.com', 'password', 'seeker')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when registration fails',
      build: () {
        when(mockRegisterUseCase('test@example.com', 'password', 'seeker'))
            .thenThrow(Exception('Registration failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested('test@example.com', 'password', 'seeker')),
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
