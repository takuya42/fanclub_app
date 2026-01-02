// lib/pages/settings_page.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/theme_provider.dart';

//import '../providers/notification_provider.dart';
import '../providers/account_id_provider.dart';
import '../services/account_id_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  /// 🔗 外部URLを開く
  Future<void> _openUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("URLを開けませんでした：$url")),
      );
    }
  }

  /// 🗑 アカウント削除処理
  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Firestoreユーザー削除（必要なら他のデータも削除）
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .delete();

      // FirebaseAuth アカウント削除
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("アカウントを削除しました")),
      );
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("削除に失敗しました：$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;
//    final notificationsEnabled = ref.watch(notificationProvider);  ←通知
    final accountIdAsync = ref.watch(userAccountIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // --------------------
          // 🔻 アカウント設定
          // --------------------
          const Padding(
            padding: EdgeInsets.all(16.0),
            child:
                Text('アカウント設定', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          // ▼ アカウントID 表示
          accountIdAsync.when(
            data: (accountId) {
              if (accountId == null) {
                return ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('アカウントID'),
                  subtitle: const Text('未作成です。'),
                  trailing: FilledButton(
                    child: const Text('作成する'),
                    onPressed: () async {
                      try {
                        final id = await AccountIdService.instance
                            .ensureForCurrentUser();
                        ref.invalidate(userAccountIdProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('作成しました：$id')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('作成に失敗：$e')),
                        );
                      }
                    },
                  ),
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('アカウントID'),
                  subtitle: Text(accountId),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: accountId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('コピーしました')),
                      );
                    },
                  ),
                );
              }
            },
            loading: () => const ListTile(
              leading: Icon(Icons.badge_outlined),
              title: Text('アカウントID'),
              subtitle: Text('読み込み中…'),
            ),
            error: (e, _) => ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('アカウントID'),
              subtitle: Text('読み込みに失敗：$e'),
            ),
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

          // --------------------
          // 🔻 アプリ設定
          // --------------------
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('アプリ設定', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('ダークモード'),
            value: isDark,
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).toggleByBool(v),
          ),

          //      SwitchListTile(
          //      secondary: const Icon(Icons.notifications_active),
          //      title: const Text('通知'),
          //       value: notificationsEnabled,
          //      onChanged: (v) async {
          //          await ref.read(notificationProvider.notifier).setEnabled(v, context);
          //      },
          //    ),

          const Divider(),

          // --------------------
          // 🔻 サポート
          // --------------------
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('サポート', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          ListTile(
            leading: const Icon(Icons.forum_rounded),
            title: const Text('お問い合わせ'),
            onTap: () => context.push('/contact'),
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('利用規約'),
            onTap: () => _openUrl(
              "https://www.notion.so/flutter-family/StagePlus-2c2b5c1f2cef807884b7c319a93f9633",
              context,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('プライバシーポリシー'),
            onTap: () => _openUrl(
              "https://www.notion.so/flutter-family/StagePlus-2c2b5c1f2cef80d4ac87ebab4d5708e4",
              context,
            ),
          ),

          // --------------------
          // 🔻 アプリ情報
          // --------------------
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final info = snapshot.data!;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('アプリ情報'),
                subtitle: Text("バージョン ${info.version}"),
              );
            },
          ),

          const Divider(),

          // ------------------------------------
          // 🔥🔥🔥 一番下：アカウント削除ボタン 🔥🔥🔥
          // ------------------------------------
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title:
                const Text('アカウントを削除する', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("本当に削除しますか？"),
                  content: const Text("この操作は取り消せません。"),
                  actions: [
                    TextButton(
                      child: const Text("キャンセル"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: const Text("削除する",
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                await _deleteAccount(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
