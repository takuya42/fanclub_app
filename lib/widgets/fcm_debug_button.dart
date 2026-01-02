// lib/widgets/fcm_debug_button.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fanclub_app/services/notification_service.dart';

class FcmDebugButton extends StatelessWidget {
  const FcmDebugButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        Platform.isIOS ? '（iOS）ローカル通知テスト' : '（Android）group_demo を購読',
      ),
      onPressed: () async {
        try {
          if (Platform.isIOS) {
            // iOSシミュレータ/実機の“前面でも”バナーUIテスト
            await NotificationService.instance.show(
              'ローカル通知テスト',
              'これはiOSバナーのテストです',
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ローカル通知を表示しました')),
              );
            }
          } else {
            // Android: 権限→トピック購読（前面受信は main.dart の onMessage + ローカル通知で表示）
            await FirebaseMessaging.instance.requestPermission(
              alert: true, badge: true, sound: true,
            );
            await FirebaseMessaging.instance.subscribeToTopic('group_demo');

            final token = await FirebaseMessaging.instance.getToken();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('topic: group_demo を購読しました。\n'
                      'token: ${token != null && token.length > 12 ? token.substring(0, 12) : token}...'),
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('エラー: $e')),
            );
          }
        }
      },
    );
  }
}
