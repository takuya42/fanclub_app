// lib/services/notification_service.dart
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ローカル通知のユーティリティ（即時/予約の両方対応）
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
  AndroidNotificationChannel(
    'fanclub_default',
    'Fanclub Notifications',
    description: 'General notifications for Fanclub app',
    importance: Importance.high,
  );

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;

    // ===== タイムゾーン初期化（予約通知に必須）=====
    // 端末タイムゾーンに合わせたい場合は flutter_native_timezone を使って取得してもOK
    tz.initializeTimeZones();
    // とりあえず東京固定（必要なら端末のタイムゾーンに差し替え）
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

    // ===== 初期化 =====
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(iOS: darwinInit, android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) async {
        // 通知タップ時のハンドリングが必要ならここに遷移処理等を書く
        // final payload = resp.payload; ...
      },
    );

    // ===== 権限リクエスト（超重要） =====
    // iOS: ローカル通知でも OS の通知権限が必要
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android: チャンネル作成（8.0+ 必須）
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    _inited = true;
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        // アプリ前面でもバナー/サウンドを出す
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.active, // iOS15+
      ),
      android: AndroidNotificationDetails(
        'fanclub_default',
        'Fanclub Notifications',
        channelDescription: 'General notifications for Fanclub app',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      ),
    );
  }

  /// 即時表示（前面でもバナーを出す）
  Future<void> show(String title, String body, {String? payload}) async {
    if (!_inited) await init();
    await _plugin.show(0, title, body, _details(), payload: payload);
  }

  /// 指定時刻にローカル通知を予約（シミュレータでもOK）
  Future<int> scheduleAt(DateTime when, String title, String body, {String? payload}) async {
    if (!_inited) await init();

    // 一意なID（簡易）
    final id = when.millisecondsSinceEpoch % 2147483647;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      _details(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null, // 繰り返しなし
      payload: payload,
    );
    return id;
  }

  /// ID指定でキャンセル
  Future<void> cancel(int id) async {
    if (!_inited) await init();
    await _plugin.cancel(id);
  }

  /// すべてのローカル通知をキャンセル
  Future<void> cancelAll() async {
    if (!_inited) await init();
    await _plugin.cancelAll();
  }
}
