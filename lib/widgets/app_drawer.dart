import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, String path, {bool replace = false}) {
    Navigator.of(context).pop(); // Drawerを閉じる
    replace ? context.go(path) : context.push(path);
  }

  // --- 外部URLを開く処理（Notion 用） ---
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("URL を開けません: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    // メニュー項目
    final menuItems = [
      {'icon': Icons.account_circle, 'title': 'マイページ', 'path': '/mypage'},
      {'icon': Icons.receipt_long, 'title': '購入履歴', 'path': '/purchase_history', 'login': true},
      {'icon': Icons.library_music, 'title': 'バンド一覧', 'path': '/bands'},
      {'icon': Icons.calendar_month, 'title': 'スケジュール', 'path': '/schedule', 'login': true},
    ];

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(),
                const Divider(color: Colors.white24, height: 1),

                if (!isLoggedIn) _buildAuthButtons(context),

                // メニューリスト本体
                ...menuItems.map((item) {
                  final requiresLogin = item['login'] == true;
                  return _menuItem(
                    context,
                    item['icon'] as IconData,
                    item['title'] as String,
                        () {
                      if (requiresLogin && !isLoggedIn) {
                        _showLoginAlert(context);
                      } else {
                        _navigate(context, item['path'] as String);
                      }
                    },
                  );
                }),

                const Divider(color: Colors.white24),

                _buildSupportSection(context),

                if (isLoggedIn)
                  _menuItem(context, Icons.logout, 'ログアウト', () => _logout(context)),

                // バージョン表示
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final info = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Version ${info.version}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Drawer 上部ロゴ ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 70),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF111111), Color(0xFF1A1A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(bottom: BorderSide(color: Colors.red, width: 1.5)),
      ),
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Stage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
            TextSpan(
              text: '＋',
              style: TextStyle(
                color: Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ログイン / 新規登録ボタン ---
  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigate(context, '/login', replace: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('ログイン', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigate(context, '/register', replace: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('新規登録', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white24, height: 32),
      ],
    );
  }

  // --- サポートセクション（Notion リンク対応） ---
  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 4),
          child: Text(
            'サポート',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),

        _menuItem(context, Icons.forum_rounded, 'お問い合わせ',
                () => _navigate(context, '/contact')),

        // 🔥 Notion の URL に置き換えてね！
        _menuItem(context, Icons.description_outlined, '利用規約',
                () => _openUrl("https://www.notion.so/flutter-family/StagePlus-2c2b5c1f2cef807884b7c319a93f9633")),

        _menuItem(context, Icons.privacy_tip_outlined, 'プライバシーポリシー',
                () => _openUrl("https://www.notion.so/flutter-family/StagePlus-2c2b5c1f2cef80d4ac87ebab4d5708e4")),

        const Divider(color: Colors.white24),
      ],
    );
  }

  // --- メニュー項目生成 ---
  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      hoverColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // --- ログアウト ---
  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.white24),
        ),
        title: const Text('本当にログアウトしますか？',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('再度ログインが必要になります。',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル', style: TextStyle(color: Colors.white)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('ログアウトしました')));
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ログアウトに失敗しました: $e')));
      }
    }
  }

  // --- ログインが必要なときのトースト ---
  void _showLoginAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Text(
          'この機能を使うにはログインが必要です',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
