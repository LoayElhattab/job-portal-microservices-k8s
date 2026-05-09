import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}