// lib/main.dart
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app_router.dart';
import 'providers/theme_provider.dart';
import 'widgets/firestore_sim_banner_listener.dart';
import 'pages/auth/session.dart';

/// ------------------------------
/// main（iOS安全構成）
/// ------------------------------
Future<void> main() async {
  // 🔴 必須：Flutterエンジン初期化
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 最優先：Firebase Core 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 認証セッション（GoRouter redirect 用）
  await session.init();

  // UI起動
  runApp(const ProviderScope(child: MyApp()));
}

/// ------------------------------
/// App Root
/// ------------------------------
class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fanclub App',
      routerConfig: appRouter,

      // Firestore 新着 → シミュレータ用バナー
      builder: (context, child) => Stack(
        children: [
          const FirestoreSimBannerListener(),
          if (child != null) child,
        ],
      ),

      themeMode: mode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      locale: const Locale('ja', 'JP'),
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
