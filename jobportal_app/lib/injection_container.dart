import 'package:get_it/get_it.dart';

// Core
import 'core/network/api_client.dart';
import 'core/network/auth_storage.dart';
// Auth Feature
import 'features/applications/data/datasources/application_remote_datasource.dart';
import 'features/applications/data/repositories/application_repository_impl.dart';
import 'features/applications/domain/repositories/application_repository.dart';
import 'features/applications/domain/usecases/apply_for_job_usecase.dart';
import 'features/applications/domain/usecases/get_applications_usecase.dart';
import 'features/applications/domain/usecases/update_application_status_usecase.dart';
import 'features/applications/presentation/manager/application_bloc.dart';
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
  // Feature: Applications
  // ===========================================================================

  sl.registerFactory(
    () => ApplicationBloc(
      applyForJobUseCase: sl(),
      getApplicationsUseCase: sl(),
      updateStatusUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => ApplyForJobUseCase(sl()));
  sl.registerLazySingleton(() => GetApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateApplicationStatusUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(sl()),
  );

  // Data Source
  sl.registerLazySingleton(() => ApplicationRemoteDataSource(sl()));

  // ===========================================================================
  // Core
  // ===========================================================================

  sl.registerLazySingleton(() => AuthStorage());
  sl.registerLazySingleton(() => ApiClient(sl()));
}
