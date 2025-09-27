// lib/pages/news/news_gate_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fanclub_app/pages/auth/session.dart';
import 'package:fanclub_app/widgets/fcm_debug_button.dart';

class NewsGatePage extends StatelessWidget {
  const NewsGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お知らせ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              session.login();         // ★ テスト用（本番では実ログイン時にのみ呼ぶ）
              context.go('/newslist'); // ルーターのredirectがあっても通過できます
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'お知らせの閲覧には会員登録/ログインが必要です',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('会員登録'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('ログイン'),
                ),
              ),
              const SizedBox(height: 24),
              // テスト用：不要になったら削除OK
              const FcmDebugButton(),
            ],
          ),
        ),
      ),
    );
  }
}
