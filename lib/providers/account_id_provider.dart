import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 現在ユーザーの accountId を返す（なければ null）
final userAccountIdProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final doc =
  await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  final data = doc.data();
  final accountId = data?['accountId'];
  if (accountId is String && accountId.trim().isNotEmpty) {
    return accountId.trim();
  }
  return null;
});
