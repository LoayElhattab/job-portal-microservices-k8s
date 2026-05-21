import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/network/auth_storage.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/job/presentation/manager/job_bloc.dart';
import '../features/job/presentation/pages/jobs_page.dart';
import '../features/job/presentation/pages/job_create_page.dart';
import '../features/job/presentation/widgets/job_card.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/notifications/presentation/widgets/notification_badge.dart';
import '../features/applications/presentation/pages/apply_page.dart';
import '../features/applications/presentation/pages/my_applications_page.dart';
import '../features/applications/presentation/pages/applicants_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';


class AppRouter {
  static final AuthStorage _authStorage = AuthStorage();

  static final GoRouter router = GoRouter(
    initialLocation: '/jobs',

    redirect: (BuildContext context, GoRouterState state) async {
     final token = await _authStorage.getToken();
      final bool isAuthenticated = token != null;
      final bool isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/jobs';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/apply',
        name: 'apply',
        builder: (context, state) {
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>? ?? {};
          final String jobId = args['jobId']?.toString() ?? '';
          final String employerId = args['employerId']?.toString() ?? '';

          return ApplyPage(
            jobId: jobId,
            employerId: employerId,
          );
        },
      ),
      GoRoute(
        path: '/my-applications',
        name: 'my_applications',
        builder: (context, state) => const MyApplicationsPage(),
      ),

      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/applicants',
        name: 'applicants',
        builder: (context, state) => const ApplicantsPage(),
      ),
      GoRoute(
        path: '/jobs',
        name: 'jobs',
        builder: (context, state) => const JobsPage(),
      ),
      GoRoute(
        path: '/create-job',
        name: 'create-job',
        builder: (context, state) => const JobCreatePage(),
      ),
    ],
  );

}