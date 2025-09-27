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
import 'pages/change_email_page.dart';

// ★ 追加
import 'pages/auth/session.dart'; // ← ログイン状態(ChangeNotifier)
import 'pages/news/news_gate_page.dart' show NewsGatePage; // ← 新規ゲートページ
// 既存
import 'pages/news/news_list_page.dart' show NewsListPage;
import 'pages/news/news_detail_page.dart' show NewsDetailPage;

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',

  // ★ 追加：session の変化でリダイレクト再評価
  refreshListenable: session,

  // ★ 追加：未ログイン→Gate、ログイン済み→NewsList
  redirect: (context, state) {
    final loggedIn = session.isLoggedIn;
    final loc = state.matchedLocation;

    final isGate = loc == '/news-gate';
    final isNews = loc.startsWith('/newslist');
    final isAuth = loc == '/login' || loc == '/register';

    // 未ログインでニュースへ来た → ゲートへ
    if (!loggedIn && isNews) return '/news-gate';

    // ログイン済みでゲート or 認証ページに居る → ニュースへ
    if (loggedIn && (isGate || isAuth)) return '/newslist';

    return null;
  },

  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('ページが見つかりません')),
    body: Center(child: Text(state.error?.toString() ?? '404')),
  ),

  routes: [
    GoRoute(path: '/login', name: 'login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/register', name: 'register', builder: (c, s) => const RegisterPage()),

    // ▼ タブ付き領域
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

        // ★ 追加：未ログイン時に表示するゲート
        GoRoute(
          path: '/news-gate',
          name: 'news_gate',
          builder: (context, state) => const NewsGatePage(),
        ),

        // 既存：ログイン済み専用のお知らせ一覧
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

        GoRoute(path: '/settings', name: 'settings', builder: (c, s) => const SettingsPage()),
        GoRoute(path: '/mypage', name: 'mypage', builder: (c, s) => const MyPage()),
      ],
    ),

    // ▼ タブ外
    GoRoute(path: '/profileEdit', name: 'profile_edit', builder: (c, s) => const ProfileEditPage()),
    GoRoute(path: '/changePassword', builder: (c, s) => const ChangePasswordPage()),
    GoRoute(path: '/changeEmail', builder: (c, s) => const ChangeEmailPage()),
  ],
);
