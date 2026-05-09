import 'package:get_it/get_it.dart';

// Core
import 'core/network/api_client.dart';
import 'core/network/auth_storage.dart';
import 'package:dio/dio.dart';
// Auth Feature
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/manager/auth_bloc.dart';
// Notification Feature
import 'features/job/data/datasourses/job_remote_datasource.dart';
import 'features/job/data/repositories/job_repository_impl.dart';
import 'features/job/domain/repositories/job_repository.dart';
import 'features/job/domain/usecases/get_jobs_usecase.dart';
import 'features/job/presentation/manager/job_bloc.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'features/notifications/presentation/manager/notification_bloc.dart';
// Applications Feature
import 'features/applications/data/datasources/application_remote_datasource.dart';
import 'features/applications/data/repositories/application_repository_impl.dart';
import 'features/applications/domain/repositories/application_repository.dart';
import 'features/applications/domain/usecases/apply_for_job_usecase.dart';
import 'features/applications/domain/usecases/get_applications_usecase.dart';
import 'features/applications/domain/usecases/update_application_status_usecase.dart';
import 'features/applications/presentation/manager/application_bloc.dart';
import 'features/profile/data/datasource/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/presentation/manager/profile_bloc.dart';
final sl = GetIt.instance;

Future<void> init() async {
  // ===========================================================================
  // Core
  // ===========================================================================

  sl.registerLazySingleton(() => AuthStorage());
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => Dio());


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
  // Feature: Notifications
  // ===========================================================================

  // BLoCs
  sl.registerFactory(
        () => NotificationBloc(
      getNotificationsUseCase: sl(),
      markNotificationReadUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<NotificationRepository>(
        () => NotificationRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton(() => NotificationRemoteDataSource(sl()));

  // ===========================================================================
  // Feature: Applications
  // ===========================================================================

  // BLoC
  sl.registerFactory(
        () => ApplicationBloc(
      getApplicationsUseCase: sl(),
      applyForJobUseCase: sl(),
      updateStatusUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => ApplyForJobUseCase(sl()));
  sl.registerLazySingleton(() => UpdateApplicationStatusUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<ApplicationRepository>(
        () => ApplicationRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton(() => ApplicationRemoteDataSource(sl()));
  // Profile Feature
  // Profile Feature
  sl.registerFactory(() => ProfileBloc(getProfileUseCase: sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(dio: sl()));
  sl.registerFactory(() => JobBloc(getJobsUseCase: sl()));
  sl.registerLazySingleton(() => GetJobsUseCase(sl()));
  sl.registerLazySingleton<JobRepository>(() => JobRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<JobRemoteDataSource>(() => JobRemoteDataSourceImpl(dio: sl()));
  // External
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton(() => Dio());
  }
}
