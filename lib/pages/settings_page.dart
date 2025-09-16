import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

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
            onTap: () => context.push('/profileEdit'), // ← ルーターへ
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
            onTap: () {
              // TODO: 遷移
            },
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
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('通知'),
            value: false,
            onChanged: (value) {
              // TODO: 保存・反映（後で実装）
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('サポート', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.forum_rounded),
            title: const Text('お問い合わせ'),
            onTap: () {
              // TODO: 遷移
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rate_outlined),
            title: const Text('レビューを書く'),
            onTap: () {
              // TODO: ストアリンクに遷移
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('利用規約'),
            onTap: () {
              // TODO: 規約ページへ遷移
            },
          ),
        ],
      ),
    );
  }
}
