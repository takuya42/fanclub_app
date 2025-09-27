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
        // 端末権限が許可済みなら念のため再購読
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

    if (enable) {
      // 権限リクエスト（iOS/Android13+）
      final settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );

      // iOS前面でOSに表示させる（Androidは既にNotificationServiceで出す想定）
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      // 許可されなかったとき
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('通知が許可されていません。端末の設定から有効にしてください。')),
          );
        }
        return;
      }

      // トピック購読
      await messaging.subscribeToTopic(topic);
      state = true;
      await prefs.setBool(_prefsKey, true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('通知をONにしました')),
        );
      }
    } else {
      // トピック解除
      await messaging.unsubscribeFromTopic(topic);
      state = false;
      await prefs.setBool(_prefsKey, false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('通知をOFFにしました')),
        );
      }
    }
  }
}
