import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError('Failed to login. Please check your credentials.'));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await registerUseCase(
          event.email,
          event.password,
          event.role,
        );
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError('Failed to register. Email might already be in use.'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await logoutUseCase.call();
      emit(AuthUnauthenticated());
    });
  }
}
