import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fanclub_app/pages/auth/session.dart'; // ← 追加

class NewsListPage extends StatelessWidget {
  const NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        if (!session.isLoggedIn) {
          // ★ ここ（未ログイン時の body）にボタンを置く
          return Scaffold(
            appBar: AppBar(title: const Text('お知らせ')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('お知らせの閲覧には会員登録/ログインが必要です',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),

                    // ← ここが「会員登録」ボタン
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
                  ],
                ),
              ),
            ),
          );
        }

        // ログイン済みの表示（リスト）
        final items = const [
          {'id': '1', 'title': 'メンテナンスのお知らせ'},
          {'id': '2', 'title': '新グッズ販売開始'},
          {'id': '3', 'title': 'イベント開催決定'},
        ];
        return Scaffold(
          appBar: AppBar(title: const Text('お知らせ')),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final n = items[i];
              return ListTile(
                title: Text(n['title']!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/newslist/${n['id']}', extra: n['title']),
              );
            },
          ),
        );
      },
    );
  }
}
