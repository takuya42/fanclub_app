import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fanclub_app/app_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          const DrawerHeader(
            child: Text(
              'メニュー',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white),
            title: const Text('プロフィール', style: TextStyle(color: Colors.white)),
            onTap: () => context.go('/mypage'),
          ),
          ListTile(
            leading: const Icon(Icons.login, color: Colors.white),
            title: const Text('ログイン', style: TextStyle(color: Colors.white)),
            onTap: () => context.go('/login'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text('通知', style: TextStyle(color: Colors.white)),
            onTap: () => context.go('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('ログアウト', style: TextStyle(color: Colors.white)),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut(); // ← ログアウト処理
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ログアウトしました')),
                  );
                  context.go('/login'); // ログイン画面へ戻す
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ログアウトに失敗しました: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
