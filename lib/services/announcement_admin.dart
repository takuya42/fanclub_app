// lib/services/announcement_admin.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementAdmin {
  AnnouncementAdmin._();

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('announcements');

  /// 質問にあったテストデータをそのまま追加
  static Future<void> addTest() async {
    await _col.add({
      'title': 'テスト本文あり',
      'preview': '短い説明（一覧用）',
      'body': '# 見出し\n本文を Markdown で書けます', // \n は改行
      'active': true,
      'publishedAt': FieldValue.serverTimestamp(), // サーバータイムスタンプ
    });
  }

  /// 汎用：任意のデータで1件追加（必要に応じて利用）
  static Future<void> add({
    required String title,
    String? preview,
    String? body,
    bool active = true,
    DateTime? publishedAt,
  }) async {
    await _col.add({
      'title': title,
      'preview': preview ?? '',
      'body': body ?? '',
      'active': active,
      'publishedAt': publishedAt != null
          ? Timestamp.fromDate(publishedAt)
          : FieldValue.serverTimestamp(),
    });
  }
}
