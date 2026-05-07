import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification.dart' as entity;
import '../manager/notification_bloc.dart';
import '../manager/notification_event.dart';

class NotificationTile extends StatelessWidget {
  final entity.Notification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: notification.isRead ? Colors.transparent : const Color(0xFFE3F2FD),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notification.message),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationBloc>().add(
              MarkNotificationAsReadEvent(notification.id)
          );
        }
      },
    );
  }
}