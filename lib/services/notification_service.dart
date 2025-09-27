import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'fanclub_channel_default';
  static const _channelName = 'お知らせ';

  /// アプリ起動時に1度だけ呼んでください（main.dart など）
  Future<void> init() async {
    // Android 初期化
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初期化（許可ダイアログは別で出すので false）
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {
        // 通知タップ時の処理が必要ならここで payload 解析して遷移
        // final payload = resp.payload;
      },
    );

    // iOS ローカル通知の権限（未許可なら一度だけ出る）
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 8.0+ 通知チャンネル
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: '前面表示用の通知チャンネル',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 前面表示用ローカル通知
  /// iOSで“UI確認だけ”したい時は forceIOS=true にする（シミュレータ対応）
  Future<void> show(
      String title,
      String body, {
        String? payload,
        bool forceIOS = false,
      }) async {
    final isAndroid = Platform.isAndroid;
    final isIosLocal = Platform.isIOS && forceIOS; // これが true の時だけ iOS でも出す

    if (isAndroid || isIosLocal) {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: '前面表示用の通知チャンネル',
          priority: Priority.defaultPriority,
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_stat_notification', // 白1色アイコンがあれば推奨
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      await _plugin.show(0, title, body, details, payload: payload);
    }
  }
}
