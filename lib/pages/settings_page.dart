import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart'; // 通知ON/OFFスイッチ用（前に作成したプロバイダ）
import '../services/notification_service.dart';   // ローカル通知（シミュレータ確認用）

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

    // 通知ON/OFFの現在値を購読
    final notificationsEnabled = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('アカウント設定', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('プロフィール編集'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profileEdit'),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('パスワード変更'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/changepassword'),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text('メールアドレス変更'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/changeemail'),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('アプリ設定', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('ダークモード'),
            value: isDark,
            onChanged: (val) =>
                ref.read(themeModeProvider.notifier).toggleByBool(val),
          ),
          ListTile(
            leading: const Icon(Icons.settings_suggest),
            title: const Text('システムに合わせる'),
            subtitle: const Text('端末の設定に合わせて自動で切り替え'),
            onTap: () =>
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
          ),

          // 通知ON/OFF（FCMトピック購読/解除 + 端末権限リクエスト）
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('通知'),
            value: notificationsEnabled,
            onChanged: (value) async {
              await ref
                  .read(notificationProvider.notifier)
                  .setEnabled(value, context);
            },
          ),

          // ====== ここが “iOSシミュレータ用の通知UIテスト” ボタン ======
          if (Platform.isIOS)
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('通知テスト（iOSシミュレータ）'),
              subtitle: const Text('ローカル通知でバナーUIだけ確認します'),
              onTap: () async {
                await NotificationService.instance.show(
                  'ローカル通知テスト',
                  'これはiOSシミュレータ用のバナーです',
                  forceIOS: true, // これがポイント！
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('テスト通知を表示しました')),
                  );
                }
              },
            ),
          // ==========================================================

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('サポート', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.forum_rounded),
            title: const Text('お問い合わせ'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.star_rate_outlined),
            title: const Text('レビューを書く'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('利用規約'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
