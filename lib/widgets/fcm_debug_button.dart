import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fanclub_app/services/notification_service.dart';

class FcmDebugButton extends StatelessWidget {
  const FcmDebugButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(Platform.isIOS
          ? '（iOS）ローカル通知テスト'
          : '（Android）group_demo を購読'),
      onPressed: () async {
        if (Platform.isIOS) {
          // ★ シミュレータで即バナーを表示
          await NotificationService.instance.show(
            'ローカル通知テスト',
            'テスト',
            forceIOS: true,
          );
        } else {
          // 従来の購読 → コンソールからトピック送信で前面バナー
          await FirebaseMessaging.instance.requestPermission(
            alert: true, badge: true, sound: true,
          );
          await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true,
          );
          await FirebaseMessaging.instance.subscribeToTopic('group_demo');
          final token = await FirebaseMessaging.instance.getToken();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('購読OK。token: ${token?.substring(0, 12)}...')),
            );
          }
        }
      },
    );
  }
}
