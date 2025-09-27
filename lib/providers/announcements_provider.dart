import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Announcement {
  final String id;
  final String title;
  final String preview;
  final DateTime time;
  final bool isRead;
  const Announcement({
    required this.id,
    required this.title,
    required this.preview,
    required this.time,
    this.isRead = false,
  });

  Announcement copyWith({bool? isRead}) => Announcement(
    id: id,
    title: title,
    preview: preview,
    time: time,
    isRead: isRead ?? this.isRead,
  );
}

class AnnouncementsController extends StateNotifier<List<Announcement>> {
  AnnouncementsController() : super(_seed);

  // ファンクラブ向けダミーデータ
  static final _seed = <Announcement>[
    Announcement(
      id: '1',
      title: 'メンテナンスのお知らせ',
      preview: '安定化のため、10/3(木) 2:00–4:00 にメンテを実施します。',
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Announcement(
      id: '2',
      title: '新グッズ販売開始（数量限定）',
      preview: '本日18:00より限定Tシャツを販売開始！在庫に限りあり。',
      time: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Announcement(
      id: '3',
      title: 'イベント開催決定',
      preview: '11/10(日) ファンミ決定。先行は来週スタート！',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  Future<void> refresh() async {
    // 後で Firestore/HTTP に差し替え
    await Future.delayed(const Duration(milliseconds: 400));
    state = List.of(state)..sort((a, b) => b.time.compareTo(a.time));
  }

  void markRead(String id) {
    state = [
      for (final n in state) n.id == id ? n.copyWith(isRead: true) : n
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  /// 即削除（Undoなし）
  void deleteById(String id) {
    state = [...state]..removeWhere((e) => e.id == id);
    // Firestoreと同期するならここで削除API等を呼ぶ
  }

  /// テスト用：ダミー1件追加
  void addDummy() {
    final now = DateTime.now();
    final item = Announcement(
      id: now.millisecondsSinceEpoch.toString(),
      title: '新着：ファンクラブからのお知らせ',
      preview: 'これはテスト通知です。本文は後で差し替えます。',
      time: now,
    );
    state = [item, ...state];
  }
}

final announcementsProvider =
StateNotifierProvider<AnnouncementsController, List<Announcement>>(
      (ref) => AnnouncementsController(),
);

final unreadAnnouncementsCountProvider = Provider<int>((ref) {
  final list = ref.watch(announcementsProvider);
  return list.where((n) => !n.isRead).length;
});
