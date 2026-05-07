import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/notification_bloc.dart';
import '../manager/notification_event.dart';
import '../manager/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());

          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications right now.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575), // Grey color
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(FetchNotificationsEvent());
              },
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  return NotificationTile(
                    notification: state.notifications[index],
                  );
                },
              ),
            );

          } else if (state is NotificationError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Color(0xFFE53935)),
                textAlign: TextAlign.center,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}