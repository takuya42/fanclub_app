import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fanclub_app/providers/announcements_provider.dart';

class NewsListPage extends ConsumerWidget {
  const NewsListPage({super.key});

  String _fmt(DateTime d) {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return now.difference(d).inDays < 1
        ? '${two(d.hour)}:${two(d.minute)}'
        : '${two(d.month)}/${two(d.day)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list   = ref.watch(announcementsProvider);
    final unread = ref.watch(unreadAnnouncementsCountProvider);
    final ctrl   = ref.read(announcementsProvider.notifier);
    final cs     = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('お知らせ'),
        actions: [
          if (unread > 0)
            TextButton(onPressed: ctrl.markAllRead, child: const Text('すべて既読')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ctrl.addDummy, // テスト追加（後でFirestore連携に差し替え可）
        icon: const Icon(Icons.add),
        label: const Text('テスト追加'),
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.refresh,
        child: list.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(Icons.notifications_none, size: 56, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            const Center(child: Text('まだお知らせはありません')),
            const SizedBox(height: 200),
          ],
        )
            : ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
              Divider(height: 0, color: cs.outlineVariant),
          itemBuilder: (context, i) {
            final n = list[i];
            final bold = n.isRead ? FontWeight.w400 : FontWeight.w700;

            return Dismissible(
              key: ValueKey(n.id),
              direction: DismissDirection.endToStart, // 右→左のみ
              background: Container(color: Colors.transparent),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8),
                    Text('削除',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              onDismissed: (_) {
                ctrl.deleteById(n.id);
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    const SnackBar(content: Text('お知らせを削除しました')),
                  );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.notifications,
                          color: cs.onPrimaryContainer),
                    ),
                    if (!n.isRead)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  n.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: bold),
                ),
                subtitle: Text(
                  n.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _fmt(n.time),
                  style: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 12),
                ),
                onTap: () {
                  ctrl.markRead(n.id);
                  context.push('/newslist/${n.id}', extra: n.title);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
