import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fanclub_app/providers/announcements_provider.dart';

class NewsDetailPage extends ConsumerStatefulWidget {
  final String id;
  final String? title;
  const NewsDetailPage({super.key, required this.id, this.title});

  @override
  ConsumerState<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends ConsumerState<NewsDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
          () => ref.read(announcementsProvider.notifier).markRead(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 本文は後で Firestore から取得に差し替え
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? '詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('お知らせID: ${widget.id}\n\n本文のダミーです。'),
      ),
    );
  }
}
