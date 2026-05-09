import 'package:flutter_test/flutter_test.dart';
import 'package:jobportal_app/features/notifications/data/models/notification_model.dart';
import 'package:jobportal_app/features/notifications/domain/entities/notification.dart';

void main() {
  final tNotificationModel = NotificationModel(
    id: 1,
    title: 'New Application',
    message: 'Someone applied for your job',
    isRead: false,
    createdAt: DateTime.parse('2026-05-09T00:00:00.000Z'),
  );

  test('should be a subclass of Notification entity', () async {
    expect(tNotificationModel, isA<Notification>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'title': 'New Application',
        'message': 'Someone applied for your job',
        'isRead': false,
        'createdAt': '2026-05-09T00:00:00.000Z',
      };
      // act
      final result = NotificationModel.fromJson(jsonMap);
      // assert
      expect(result.id, tNotificationModel.id);
      expect(result.title, tNotificationModel.title);
      expect(result.isRead, tNotificationModel.isRead);
    });
  });
}
