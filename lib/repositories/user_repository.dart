import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  static Future<void> createIfNeeded(User user, String provider) async {
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final snap = await doc.get();

    if (!snap.exists) {
      await doc.set({
        'uid': user.uid,
        'email': user.email ?? '',           // ← null対策
        'name': user.displayName ?? 'Guest', // ← null対策
        'provider': provider,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
