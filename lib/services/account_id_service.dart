import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// アカウントIDの生成・確保（ユニーク保証）
class AccountIdService {
  AccountIdService._();
  static final AccountIdService instance = AccountIdService._();

  final _users = FirebaseFirestore.instance.collection('users');
  // ユニークを保証するための予約テーブル（ドキュメントID=accountId）
  final _reserved = FirebaseFirestore.instance.collection('account_ids');

  /// 現在ユーザーの accountId を必ず返す。
  /// すでに持っていればそれを返し、なければ新規に払い出して Firestore に保存。
  Future<String> ensureForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('ログインしていません');
    }

    // 既に設定済みならそのまま返す
    final userDoc = await _users.doc(user.uid).get();
    final current = userDoc.data()?['accountId'];
    if (current is String && current.trim().isNotEmpty) {
      return current.trim();
    }

    // 未設定なら新規払い出し（候補をいくつか試す）
    for (int i = 0; i < 8; i++) {
      final candidate = _generateCandidate(user);
      final ok = await _tryReserveAndWrite(user.uid, candidate);
      if (ok) return candidate;
    }
    throw StateError('アカウントIDの払い出しに失敗しました（混雑）');
  }

  /// 英数字とアンダースコアのみ。先頭は英字。
  static final _validRe = RegExp(r'^[a-z][a-z0-9_]{2,20}$');

  /// ユーザーに基づく候補を作る（重複回避のためランダム添字）
  String _generateCandidate(User user) {
    final base = (user.email ?? user.uid).split('@').first;
    final slug = base
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final head = slug.isEmpty || !RegExp(r'^[a-z]').hasMatch(slug[0]) ? 'u' : '';
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    final candidate = (head + slug).replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final trimmed = (candidate.length > 16 ? candidate.substring(0, 16) : candidate);
    final id = '$trimmed$rand'; // 例: name1234
    return _validRe.hasMatch(id) ? id : 'u$rand';
  }

  /// 予約テーブルと users/{uid} をトランザクションで同時更新
  Future<bool> _tryReserveAndWrite(String uid, String accountId) async {
    final resRef = _reserved.doc(accountId);
    final userRef = _users.doc(uid);

    return FirebaseFirestore.instance.runTransaction<bool>((tx) async {
      final reserved = await tx.get(resRef);
      if (reserved.exists) {
        // すでに他人が確保済み
        return false;
      }

      // users/{uid} にも書き込む（マージ）
      tx.set(resRef, {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(userRef, {
        'accountId': accountId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    });
  }
}
