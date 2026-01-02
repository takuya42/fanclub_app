// lib/pages/news/news_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsDetailPage extends StatefulWidget {
  final String id;
  final String? title;

  const NewsDetailPage({super.key, required this.id, this.title});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String? title;
  String? body;
  String? type;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAnnouncement();
  }

  /// 🔹 Firestoreからお知らせを取得
  Future<void> _loadAnnouncement() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.id)
          .get();

      if (!doc.exists) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      setState(() {
        title = data['title'] ?? widget.title ?? 'お知らせ';
        body = data['preview'] ?? data['body'] ?? '本文がありません。';
        type = data['type'] ?? 'admin';
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Firestore取得エラー: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('読み込み中...'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('エラー'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'お知らせの読み込みに失敗しました。',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title ?? 'お知らせ'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (type == 'admin')
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '運営からのお知らせ',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              MarkdownBody(
                data: body ?? '本文がありません。',
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
