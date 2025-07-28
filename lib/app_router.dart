import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'login_page.dart';
import 'home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final email = state.extra as String?;
        return HomePage(email: email);
      },
    ),
  ],
);
