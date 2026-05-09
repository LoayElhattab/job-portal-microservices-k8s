import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jobportal_app/core/network/api_client.dart';
import 'package:jobportal_app/core/network/auth_storage.dart';
import 'package:jobportal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:jobportal_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jobportal_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:jobportal_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:jobportal_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jobportal_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jobportal_app/features/job/domain/repositories/job_repository.dart';
import 'package:jobportal_app/features/job/data/datasources/job_remote_datasource.dart';
import 'package:jobportal_app/features/job/domain/usecases/get_jobs_usecase.dart';
import 'package:jobportal_app/features/applications/domain/repositories/application_repository.dart';
import 'package:jobportal_app/features/applications/data/datasources/application_remote_datasource.dart';
import 'package:jobportal_app/features/applications/domain/usecases/get_applications_usecase.dart';
import 'package:jobportal_app/features/applications/domain/usecases/apply_for_job_usecase.dart';
import 'package:jobportal_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:jobportal_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:jobportal_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:jobportal_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:jobportal_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:jobportal_app/features/profile/domain/usecases/get_profile_usecase.dart';

@GenerateMocks([
  Dio,
  ApiClient,
  AuthStorage,
  FlutterSecureStorage,
  RequestInterceptorHandler,
  ErrorInterceptorHandler,
  ResponseInterceptorHandler,
  AuthRepository,
  AuthRemoteDataSource,
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  JobRepository,
  JobRemoteDataSource,
  GetJobsUseCase,
  ApplicationRepository,
  ApplicationRemoteDataSource,
  GetApplicationsUseCase,
  ApplyForJobUseCase,
  NotificationRepository,
  NotificationRemoteDataSource,
  GetNotificationsUseCase,
  ProfileRepository,
  ProfileRemoteDataSource,
  GetProfileUseCase,
])
void main() {}
