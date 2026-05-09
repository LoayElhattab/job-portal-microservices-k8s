import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/app_routes.dart';
import 'features/applications/presentation/manager/application_bloc.dart';
import 'features/auth/presentation/manager/auth_bloc.dart';
import 'features/notifications/presentation/manager/notification_bloc.dart';
import 'injection_container.dart';

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<NotificationBloc>(create: (_) => sl<NotificationBloc>()),
        BlocProvider<ApplicationBloc>(create: (_) => sl<ApplicationBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Job Portal System',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
