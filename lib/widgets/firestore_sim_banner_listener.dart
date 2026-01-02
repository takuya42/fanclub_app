// lib/widgets/firestore_sim_banner_listener.dart
// Firestoreの announcements に新規ドキュメントが増えたら
// iOS（主にシミュレータ）でローカル通知バナーを出す不可視ウィジェット。

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fanclub_app/providers/announcements_provider.dart'
    show Announcement, announcementsStreamProvider;
import 'package:fanclub_app/services/notification_service.dart';

class FirestoreSimBannerListener extends ConsumerStatefulWidget {
  const FirestoreSimBannerListener({super.key});

  @override
  ConsumerState<FirestoreSimBannerListener> createState() =>
      _FirestoreSimBannerListenerState();
}

class _FirestoreSimBannerListenerState
    extends ConsumerState<FirestoreSimBannerListener> {
  bool _initialized = false;
  Set<String> _seenIds = <String>{};

  @override
  Widget build(BuildContext context) {
    // Firestoreのストリーム（AsyncValue<List<Announcement>>）を監視
    ref.listen(announcementsStreamProvider, (prev, next) async {
      // シミュレータ用途：iOSのみ。実機二重表示の事故を避けるため。
      if (!Platform.isIOS) return;

      next.whenData((List<Announcement> list) async {
        final currentIds = list.map((e) => e.id).toSet();

        // 初回は既存分に対して通知しない（差分検出の初期化）
        if (!_initialized) {
          _seenIds = currentIds;
          _initialized = true;
          return;
        }

        // 新規追加IDだけ抽出
        final newIds = currentIds.difference(_seenIds);
        if (newIds.isNotEmpty) {
          for (final a in list.where((e) => newIds.contains(e.id))) {
            // iOSでローカル通知を即時表示（前面でもバナー）
            await NotificationService.instance.show(
              a.title.isEmpty ? 'お知らせ' : a.title,
              a.preview.isEmpty ? '新しいお知らせがあります' : a.preview,
              // NotificationService に forceIOS パラメータがある場合は残してOK
              // forceIOS: true,
            );
          }
        }

        _seenIds = currentIds;
      });
    });

    // UIには何も描画しない
    return const SizedBox.shrink();
  }
}
