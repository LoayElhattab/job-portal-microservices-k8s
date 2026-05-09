abstract class NotificationEvent {}

class FetchNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;
  MarkNotificationAsReadEvent(this.notificationId);
}