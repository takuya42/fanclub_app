import 'package:fanclub_app/pages/mypage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/app_drawer.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'layouts/bottom_nav_layout.dart';
import 'pages/settings_page.dart';
import 'pages/register/register_page.dart';
import 'pages/profile_edit_page.dart';
import 'pages/change_password_page.dart';


// ← 競合防止のため show を使う
import 'pages/news/news_list_page.dart' show NewsListPage;
import 'pages/news/news_detail_page.dart' show NewsDetailPage;

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('ページが見つかりません')),
    body: Center(child: Text(state.error?.toString() ?? '404')),
  ),
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

    // ▼ タブ付き領域（BottomNavLayout の中）
    ShellRoute(
      builder: (context, state, child) => BottomNavLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) {
            final email = state.extra as String?;
            return HomePage(email: email);
          },
        ),
        GoRoute(
          path: '/newslist',
          name: 'newslist',
          builder: (context, state) => const NewsListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'news_detail',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                final title = state.extra as String?;
                return NewsDetailPage(id: id, title: title);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/mypage',
          name: 'mypage',
          builder: (context, state) => const MyPage(),
        ),
      ],
    ),

    // ▼ タブなしで開く編集画面（Shell の外）
    GoRoute(
      path: '/profileEdit',
      name: 'profile_edit',
      builder: (context, state) => const ProfileEditPage(),
    ),
    GoRoute(
      path: '/changePassword',
      builder: (context, state) => const ChangePasswordPage(),
    ),

  ],
);
