import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 運営からのお知らせモデル
@immutable
class Announcement {
  final String id;
  final String title;
  final String preview; // 一覧に表示する短文 or 本文の先頭
  final DateTime time;
  final bool isRead;
  final String? type; // Firestoreのtypeフィールド（今回は"admin"固定）

  const Announcement({
    required this.id,
    required this.title,
    required this.preview,
    required this.time,
    this.isRead = false,
    this.type,
  });

  Announcement copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? time,
    bool? isRead,
    String? type,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  /// Firestore → モデル変換
  factory Announcement.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final ts = data['publishedAt'];
    DateTime publishedAt;
    if (ts is Timestamp) {
      publishedAt = ts.toDate();
    } else if (ts is DateTime) {
      publishedAt = ts;
    } else {
      publishedAt = DateTime.now();
    }

    return Announcement(
      id: doc.id,
      title: (data['title'] as String?)?.trim() ?? '',
      preview: (data['preview'] as String?)?.trim() ?? '',
      time: publishedAt,
      isRead: false,
      type: (data['type'] as String?)?.trim() ?? 'admin',
    );
  }

  /// Firestore書き込み用
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'preview': preview,
      'publishedAt': Timestamp.fromDate(time),
      'type': type ?? 'admin', // デフォルトで運営
      'active': true,
    };
  }
}

/// 🔹 Firestore購読：運営(type == 'admin')のみ
final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  final q = FirebaseFirestore.instance
      .collection('announcements')
      .where('active', isEqualTo: true)
      .where('type', isEqualTo: 'admin') // ← ここで運営限定
      .orderBy('publishedAt', descending: true)
      .withConverter<Map<String, dynamic>>(
    fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
    toFirestore: (data, _) => data,
  );

  return q.snapshots().map((snap) {
    return snap.docs
        .map((doc) =>
        Announcement.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  });
});

/// 🔹 1件ドキュメント購読（詳細ページなどで使用）
final announcementDocProvider =
StreamProvider.family<Announcement?, String>((ref, id) {
  final doc = FirebaseFirestore.instance
      .collection('announcements')
      .doc(id)
      .withConverter<Map<String, dynamic>>(
    fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
    toFirestore: (data, _) => data,
  );

  return doc.snapshots().map((snap) {
    if (!snap.exists) return null;

    final map = snap.data()!;
    final base =
    Announcement.fromFirestore(snap as DocumentSnapshot<Map<String, dynamic>>);

    final body = (map['body'] as String?)?.trim();
    return (body == null || body.isEmpty)
        ? base
        : base.copyWith(preview: body);
  });
});

/// 🔹 既読制御
class AnnouncementReadsController extends StateNotifier<Set<String>> {
  AnnouncementReadsController() : super(<String>{});

  bool isRead(String id) => state.contains(id);

  void markRead(String id) {
    if (state.contains(id)) return;
    state = {...state, id};
  }

  void markAllRead(Iterable<String> ids) {
    state = {...state, ...ids};
  }

  void clear() {
    state = <String>{};
  }
}

final announcementReadsProvider =
StateNotifierProvider<AnnouncementReadsController, Set<String>>(
      (ref) => AnnouncementReadsController(),
);

/// 🔹 一覧 + 既読付与
final announcementsProvider = Provider<List<Announcement>>((ref) {
  final asyncList = ref.watch(announcementsStreamProvider);
  final reads = ref.watch(announcementReadsProvider);

  return asyncList.maybeWhen(
    data: (list) =>
        list.map((a) => a.copyWith(isRead: reads.contains(a.id))).toList(),
    orElse: () => const <Announcement>[],
  );
});

/// 🔹 未読件数
final unreadAnnouncementsCountProvider = Provider<int>((ref) {
  final asyncList = ref.watch(announcementsStreamProvider);
  final reads = ref.watch(announcementReadsProvider);

  return asyncList.maybeWhen(
    data: (list) => list.where((a) => !reads.contains(a.id)).length,
    orElse: () => 0,
  );
});

/// 🔹 UIコントローラ
class AnnouncementsUiController {
  AnnouncementsUiController(this._ref);
  final Ref _ref;

  void markRead(String id) {
    _ref.read(announcementReadsProvider.notifier).markRead(id);
  }

  void markAllRead(Iterable<String> ids) {
    _ref.read(announcementReadsProvider.notifier).markAllRead(ids);
  }
}

final announcementsUiControllerProvider =
Provider<AnnouncementsUiController>((ref) {
  return AnnouncementsUiController(ref);
});
