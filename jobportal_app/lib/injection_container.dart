import 'package:get_it/get_it.dart';

// Core
import 'core/network/api_client.dart';
import 'core/network/auth_storage.dart';
// Auth Feature
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/manager/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===========================================================================
  // Feature: Auth
  // ===========================================================================

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Data Sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));

  // ===========================================================================
  // Core
  // ===========================================================================

  sl.registerLazySingleton(() => AuthStorage());
  sl.registerLazySingleton(() => ApiClient(sl()));
}
