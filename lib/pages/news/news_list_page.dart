import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fanclub_app/providers/announcements_provider.dart';
import 'package:go_router/go_router.dart';

class NewsListPage extends ConsumerWidget {
  const NewsListPage({super.key});

  String _fmt(DateTime d) {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return now.difference(d).inDays < 1
        ? '${two(d.hour)}:${two(d.minute)}'
        : '${d.month}/${d.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Firestoreの全お知らせ
    final allList = ref.watch(announcementsProvider);
    // 🔸 運営からのお知らせのみ抽出
    final adminNews = allList.where((e) => e.type == 'admin').toList();

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('運営からのお知らせ'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _buildListView(context, cs, adminNews),
    );
  }

  /// 🔹 リストビュー部分
  Widget _buildListView(
      BuildContext context, ColorScheme cs, List<dynamic> list) {
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 300),
          Center(
            child: Text(
              'まだお知らせはありません',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: Colors.redAccent,
      onRefresh: () async =>
      await Future<void>.delayed(const Duration(milliseconds: 400)),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            Divider(height: 0, color: cs.outlineVariant),
        itemBuilder: (context, i) {
          final n = list[i];
          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.campaign, color: cs.onPrimaryContainer),
            ),
            title: Text(
              n.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              n.preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              _fmt(n.time),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            onTap: () {
              // 詳細ページへ遷移
              context.push('/newslist/${n.id}', extra: n.title);
            },
          );
        },
      ),
    );
  }
}
