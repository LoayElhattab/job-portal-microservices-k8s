import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:jobportal_app/core/network/api_client.dart';
import 'package:jobportal_app/core/network/auth_storage.dart';
import 'package:jobportal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:jobportal_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jobportal_app/features/job/domain/repositories/job_repository.dart';
import 'package:jobportal_app/features/job/data/datasources/job_remote_datasource.dart';
import 'package:jobportal_app/features/applications/domain/repositories/application_repository.dart';
import 'package:jobportal_app/features/applications/data/datasources/application_remote_datasource.dart';
import 'package:jobportal_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:jobportal_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:jobportal_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:jobportal_app/features/profile/data/datasources/profile_remote_datasource.dart';

@GenerateMocks([
  Dio,
  ApiClient,
  AuthStorage,
  AuthRepository,
  AuthRemoteDataSource,
  JobRepository,
  JobRemoteDataSource,
  ApplicationRepository,
  ApplicationRemoteDataSource,
  NotificationRepository,
  NotificationRemoteDataSource,
  ProfileRepository,
  ProfileRemoteDataSource,
])
void main() {}
