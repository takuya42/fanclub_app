import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String? email; // 仮にログイン時のメールアドレスを受け取る

  const HomePage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // ログアウト処理（仮）
              Navigator.pop(context); // ログイン画面に戻るだけ
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ようこそ、${email ?? "ゲスト"}さん！',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              '🎉 ファンクラブの投稿一覧（準備中）',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
