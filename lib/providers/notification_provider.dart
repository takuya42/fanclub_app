// lib/providers/notification_provider.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationProvider =
StateNotifierProvider<NotificationController, bool>(
      (ref) => NotificationController(ref)..load(),
);

class NotificationController extends StateNotifier<bool> {
  NotificationController(this.ref) : super(false);

  final Ref ref;
  static const _prefsKey = 'notifications_enabled';
  // 本番では全体配信用などに変更可（例: 'news'）
  static const String topic = 'group_demo';

  /// 起動時に保存値を読み込み、ONなら購読を再適用
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefsKey);
    if (saved != null) {
      state = saved;
      if (state) {
        // 起動時の購読再適用（失敗しても無視）
        try {
          await FirebaseMessaging.instance.subscribeToTopic(topic);
        } catch (_) {}
      }
    }
  }

  /// スイッチ操作でON/OFF
  Future<void> setEnabled(bool enable, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final messaging = FirebaseMessaging.instance;

    try {
      if (enable) {
        // ✅ 通知権限リクエスト（iOS / Android 13+）
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        // iOSで前面通知を表示
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // 拒否された場合
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('通知が許可されていません。端末の設定から有効にしてください。')),
            );
          }
          return;
        }

        // ✅ iOSの場合はAPNsトークンが発行されるまで待機
        if (Platform.isIOS) {
          String? token;
          int retry = 0;

          while (token == null && retry < 5) {
            token = await messaging.getAPNSToken();
            if (token == null) {
              await Future.delayed(const Duration(milliseconds: 400));
              retry++;
            }
          }

          if (token == null) {
            debugPrint('[Warning] APNsトークンが未取得のままですが続行します');
          }
        }

        // ✅ トピック購読
        await messaging.subscribeToTopic(topic);
        state = true;
        await prefs.setBool(_prefsKey, true);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('通知をONにしました')),
          );
        }
      } else {
        // トピック購読解除
        await messaging.unsubscribeFromTopic(topic);
        state = false;
        await prefs.setBool(_prefsKey, false);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('通知をOFFにしました')),
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ 通知設定中にエラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('通知設定に失敗しました：$e')),
        );
      }
    }
  }
}
