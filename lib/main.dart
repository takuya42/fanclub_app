import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'app_router.dart'; // ← ルーター定義
import 'providers/theme_provider.dart'; // テーマのプロバイダ
import 'services/notification_service.dart'; // ★ 追加：前面バナー用（Android）

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  // バックグラウンド受信時に必要
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _initFcmAndNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // iOS / Android13+ 権限
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // iOS：前面でもOSにバナー/音/バッジを出させる
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, badge: true, sound: true,
  );

  // Android前面バナー用（ローカル通知）
  if (Platform.isAndroid) {
    await NotificationService.instance.init();
  }

  // BG受信ハンドラ
  FirebaseMessaging.onBackgroundMessage(_bgHandler);

  // 前面受信（Androidのみローカル通知でバナー表示）
  FirebaseMessaging.onMessage.listen((msg) {
    final title = msg.notification?.title ?? 'お知らせ';
    final body  = msg.notification?.body  ?? '内容をチェックしてね';

    // 画面遷移用のデータ（任意）
    final postId = msg.data['postId'];

    if (Platform.isAndroid) {
      final payload = (postId != null) ? 'postId=$postId' : null;
      NotificationService.instance.show(title, body, payload: payload);
    }
    // iOSは setForegroundNotificationPresentationOptions でOSが表示する（重複防止のためローカル通知は出さない）
  });

  // 通知タップで復帰/起動（アプリが生きているとき）
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    final postId = msg.data['postId'];
    if (postId != null) {
      appRouter.go('/newslist/$postId'); // 例：ニュース詳細へ
    }
  });

  // アプリ完全終了 → 通知タップで起動（初回のみ）
  final initMsg = await FirebaseMessaging.instance.getInitialMessage();
  if (initMsg != null) {
    final postId = initMsg.data['postId'];
    if (postId != null) {
      // ルーターが立ち上がってから遷移
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.go('/newslist/$postId');
      });
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initFcmAndNotifications(); // ★ 追加：runAppより前に一度だけ
  runApp(const ProviderScope(child: MyApp()));
}

// ★ HookConsumerWidget（既存どおり）
class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fanclub App',
      routerConfig: appRouter,

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
      supportedLocales: const [Locale('ja', 'JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
