import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementRepository {
  AnnouncementRepository._();
  static final instance = AnnouncementRepository._();

  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // users/{uid}/announcement_states の購読（既読/削除状態）
  Stream<List<Map<String, dynamic>>> statesStream() {
    return _db
        .collection('users').doc(_uid)
        .collection('announcement_states')
        .snapshots()
        .map((qs) => qs.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> markRead(String id) => _db
      .collection('users').doc(_uid)
      .collection('announcement_states').doc(id)
      .set({'isRead': true, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true));

  Future<void> delete(String id) => _db
      .collection('users').doc(_uid)
      .collection('announcement_states').doc(id)
      .set({'deleted': true, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true));
}
