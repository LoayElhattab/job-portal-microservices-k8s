import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markNotificationReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationInitial()) {

    on<FetchNotificationsEvent>((event, emit) async {
      emit(NotificationLoading());
      try {
        final notifications = await getNotificationsUseCase();
        emit(NotificationLoaded(notifications));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    on<MarkNotificationAsReadEvent>((event, emit) async {
      if (state is NotificationLoaded) {
        try {
          await markNotificationReadUseCase(event.notificationId);
          add(FetchNotificationsEvent());
        } catch (e) {
          emit(NotificationError(e.toString()));
        }
      }
    });
  }
}