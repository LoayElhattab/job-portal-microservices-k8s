import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Notification>> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String id) async {
    await remoteDataSource.markAsRead(id);
  }
}