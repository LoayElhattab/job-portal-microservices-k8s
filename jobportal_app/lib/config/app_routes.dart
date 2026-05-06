import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/network/auth_storage.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';

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
        path: '/jobs',
        name: 'jobs',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Jobs Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _authStorage.deleteToken();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          body: const Center(
            child: Text(
              '🚀 Router & Auth Configured!\nJobs List Coming Soon.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    ],
  );
}
