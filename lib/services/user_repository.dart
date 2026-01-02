import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  UserRepository._();
  static final instance = UserRepository._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// ログイン中ユーザーの users/{uid} を作成/更新（初回は createdAt も入れる）
  Future<void> ensureCurrentUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    final base = <String, dynamic>{
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      await ref.set({
        ...base,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await ref.set(base, SetOptions(merge: true));
    }
  }

  /// （任意）FCMトークンを保存したい場合用
  Future<void> upsertFcmToken(String token, {required String platform}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = _db.collection('users').doc(user.uid);
    await ref.set({
      'fcmTokens': {
        token: {
          'platform': platform,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }
    }, SetOptions(merge: true));
  }
}
