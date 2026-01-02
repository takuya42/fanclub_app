import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoodsItem {
  final String id;
  final String name;
  final int price;
  final DateTime date;
  final String? imageUrl;

  GoodsItem({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    this.imageUrl,
  });

  factory GoodsItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoodsItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }
}

final goodsHistoryProvider = StreamProvider<List<GoodsItem>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('goods_history')
      .where('userId', isEqualTo: user.uid)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => GoodsItem.fromDoc(doc)).toList());
});
