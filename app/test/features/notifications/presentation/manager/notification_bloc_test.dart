import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jobportal_app/features/notifications/domain/entities/notification.dart';
import 'package:jobportal_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:jobportal_app/features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'package:jobportal_app/features/notifications/presentation/manager/notification_bloc.dart';
import 'package:jobportal_app/features/notifications/presentation/manager/notification_event.dart';
import 'package:jobportal_app/features/notifications/presentation/manager/notification_state.dart';

class MockGetNotificationsUseCase extends Mock implements GetNotificationsUseCase {}
class MockMarkAsReadUseCase extends Mock implements MarkAsReadUseCase {}

void main() {
  late NotificationBloc notificationBloc;
  late MockGetNotificationsUseCase mockGetNotificationsUseCase;
  late MockMarkAsReadUseCase mockMarkAsReadUseCase;

  setUp(() {
    mockGetNotificationsUseCase = MockGetNotificationsUseCase();
    mockMarkAsReadUseCase = MockMarkAsReadUseCase();
    notificationBloc = NotificationBloc(
      getNotificationsUseCase: mockGetNotificationsUseCase,
      markNotificationReadUseCase: mockMarkAsReadUseCase,
    );
  });

  tearDown(() {
    notificationBloc.close();
  });

  final tNotifications = [
    Notification(
      id: 1,
      title: 'Title',
      message: 'Message',
      isRead: false,
      createdAt: DateTime.now(),
    )
  ];

  test('initial state should be NotificationInitial', () {
    expect(notificationBloc.state, isA<NotificationInitial>());
  });

  group('FetchNotificationsEvent', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationLoaded] when successful',
      build: () {
        when(mockGetNotificationsUseCase()).thenAnswer((_) async => tNotifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(FetchNotificationsEvent()),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when failure occurs',
      build: () {
        when(mockGetNotificationsUseCase()).thenThrow(Exception('Error'));
        return notificationBloc;
      },
      act: (bloc) => bloc.add(FetchNotificationsEvent()),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );
  });
}
