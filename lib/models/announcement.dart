import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String preview;
  final String? body;
  final DateTime publishedAt;
  final bool active;

  Announcement({
    required this.id,
    required this.title,
    required this.preview,
    required this.publishedAt,
    required this.active,
    this.body,
  });

  factory Announcement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Announcement(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      preview: (d['preview'] ?? '') as String,
      body: d['body'] as String?,
      active: (d['active'] ?? true) as bool,
      publishedAt: (d['publishedAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }
}
