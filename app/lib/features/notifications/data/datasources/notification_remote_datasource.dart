import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSource(this.apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.dio.get('/notifications');
    return (response.data['data'] as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await apiClient.dio.patch('/notifications/$id/read');
  }
}