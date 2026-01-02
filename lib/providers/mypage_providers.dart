// lib/providers/mypage_providers.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class MyProfile {
  final bool signedIn;
  final String? uid;
  final String? displayName;
  final String? email;
  final String? accountId;
  final String? photoUrl;
  final DateTime? createdAt;

  const MyProfile({
    required this.signedIn,
    this.uid,
    this.displayName,
    this.email,
    this.accountId,
    this.photoUrl,
    this.createdAt,
  });

  factory MyProfile.signedOut() => const MyProfile(signedIn: false);

  factory MyProfile.fromFirestore(User user, Map<String, dynamic>? data) {
    DateTime? created;
    final ts = data?['createdAt'];
    if (ts is Timestamp) created = ts.toDate();
    if (ts is DateTime) created = ts;

    return MyProfile(
      signedIn: true,
      uid: user.uid,
      displayName: data?['displayName'] as String? ?? user.displayName,
      email: user.email,
      accountId: data?['accountId'] as String?,
      photoUrl: data?['photoUrl'] as String? ?? user.photoURL,
      createdAt: created,
    );
  }
}

/// FirebaseAuth のユーザー変化を購読
final authUserProvider = StreamProvider<User?>(
      (ref) => FirebaseAuth.instance.userChanges(),
);

/// users/{uid} ドキュメントのスナップショットを購読
final userDocProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>(
      (ref) {
    final auth = ref.watch(authUserProvider).value;
    if (auth == null) {
      // 未ログイン時は空ストリーム
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(auth.uid)
        .snapshots();
  },
);

/// マイページ表示用のプロフィールを一発で取得できる StreamProvider
final myProfileStreamProvider = StreamProvider<MyProfile>((ref) async* {
  await for (final user in FirebaseAuth.instance.userChanges()) {
    if (user == null) {
      yield MyProfile.signedOut();
      continue;
    }
    // users/{uid} を追従
    await for (final snap in FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()) {
      yield MyProfile.fromFirestore(user, snap.data());
    }
  }
});

/// 画面から呼び出す操作（サインアウト等）
class MyPageController {
  MyPageController(this._ref);
  final Ref _ref;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void refreshProfile() {
    // Riverpodのキャッシュを明示的に更新したい場合
    _ref.invalidate(userDocProvider);
    _ref.invalidate(myProfileStreamProvider);
  }
}

final myPageControllerProvider = Provider<MyPageController>(
      (ref) => MyPageController(ref),
);
