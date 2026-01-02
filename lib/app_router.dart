import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ===== Pages =====
import 'login_page.dart';
import 'home_page.dart';
import 'layouts/bottom_nav_layout.dart';
import 'pages/settings_page.dart';
import 'pages/register/register_page.dart';
import 'pages/change_password_page.dart';
import 'pages/change_email_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/webview/contact_webview_page.dart';
import 'pages/mypage.dart';
import 'pages/membership_page.dart';
import 'pages/goods_history_page.dart';
import 'pages/cart_page.dart';
import 'pages/payment_page.dart';
import 'pages/purchase_complete_page.dart';
import 'pages/band_list_page.dart';
import 'pages/schedule/schedule_page.dart';
import 'pages/splash_page.dart';
import 'pages/goods_list_page.dart';

// Terms
import 'pages/terms_page.dart';
import 'pages/privacy_page.dart';

// Auth
import 'pages/auth/session.dart';

// News
import 'pages/news/news_gate_page.dart';
import 'pages/news/news_list_page.dart';
import 'pages/news/news_detail_page.dart';

/// ===============================
/// GoRouter
/// ===============================
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: session,

  /// 🔴 リダイレクト（重要）
  redirect: (context, state) {
    final loc = state.matchedLocation;

    // Splash は必ず許可
    if (loc == '/splash') return null;

    final loggedIn = session.isLoggedIn;

    final isGate = loc == '/news-gate';
    final isNews = loc.startsWith('/newslist');
    final isAuth =
        loc == '/login' || loc == '/register' || loc == '/forgotPassword';

    if (!loggedIn && isNews) return '/news-gate';
    if (loggedIn && (isGate || isAuth)) return '/home';

    return null;
  },

  errorBuilder: (context, state) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(title: const Text('ページが見つかりません')),
    body: Center(
      child: Text(
        state.error?.toString() ?? '404 Not Found',
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ),

  routes: [
    // ===============================
    // Splash
    // ===============================
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // ===============================
    // Auth
    // ===============================
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
      path: '/forgotPassword',
      name: 'forgot_password',
      builder: (context, state) {
        final email = state.extra as String?;
        return ForgotPasswordPage(initialEmail: email);
      },
    ),

    // ===============================
    // Terms / Privacy
    // ===============================
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => const TermsPage(),
    ),
    GoRoute(
      path: '/privacy',
      name: 'privacy',
      builder: (context, state) => const PrivacyPage(),
    ),

    // ===============================
    // BottomNavigation
    // ===============================
    ShellRoute(
      builder: (context, state, child) =>
          BottomNavLayout(child: child),
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
          path: '/mypage',
          name: 'mypage',
          builder: (context, state) => const MyPage(),
        ),

        // News
        GoRoute(
          path: '/news-gate',
          name: 'news_gate',
          builder: (context, state) => const NewsGatePage(),
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
                final id = state.pathParameters['id']!;
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
          path: '/membership',
          name: 'membership',
          builder: (context, state) => const MembershipPage(),
        ),
        GoRoute(
          path: '/bands',
          name: 'bands',
          builder: (context, state) => const BandListPage(),
        ),
        GoRoute(
          path: '/schedule',
          name: 'schedule',
          builder: (context, state) => const SchedulePage(),
        ),
      ],
    ),

    // ===============================
    // Outside Tabs
    // ===============================
    GoRoute(
      path: '/shop',
      name: 'shop',
      builder: (context, state) => const GoodsListPage(),
    ),
    GoRoute(
      path: '/purchase_history',
      name: 'purchase_history',
      builder: (context, state) => const GoodsHistoryPage(),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) => const PaymentPage(),
    ),
    GoRoute(
      path: '/purchase-complete',
      name: 'purchase_complete',
      builder: (context, state) => const PurchaseCompletePage(),
    ),
    GoRoute(
      path: '/changepassword',
      name: 'change_password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/changeemail',
      name: 'change_email',
      builder: (context, state) => const ChangeEmailPage(),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) => const ContactWebViewPage(),
    ),
  ],
);
