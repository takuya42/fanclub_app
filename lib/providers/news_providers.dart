import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement.dart';

/// 🔹 ユーザー向け（type: "user"）
final userNewsProvider = StreamProvider<List<Announcement>>((ref) {
  final snapshots = FirebaseFirestore.instance
      .collection('announcements')
      .where('type', isEqualTo: 'user')
      .where('active', isEqualTo: true)
      .orderBy('publishedAt', descending: true)
      .snapshots();

  return snapshots.map((snapshot) =>
      snapshot.docs.map((doc) => Announcement.fromDoc(doc)).toList());
});

/// 🔹 運営から（type: "admin"）
final adminNewsProvider = StreamProvider<List<Announcement>>((ref) {
  final snapshots = FirebaseFirestore.instance
      .collection('announcements')
      .where('type', isEqualTo: 'admin')
      .where('active', isEqualTo: true)
      .orderBy('publishedAt', descending: true)
      .snapshots();

  return snapshots.map((snapshot) =>
      snapshot.docs.map((doc) => Announcement.fromDoc(doc)).toList());
});
