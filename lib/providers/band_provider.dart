import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Band {
  final String id;
  final String name;
  final String genre;
  final String description;
  final String imageUrl;
  final String pageType;

  Band({
    required this.id,
    required this.name,
    required this.genre,
    required this.description,
    required this.imageUrl,
    this.pageType = 'default',
  });

  factory Band.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Band(
      id: doc.id,
      name: data['name'] ?? '',
      genre: data['genre'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      pageType: data['pageType'] ?? 'default',
    );
  }
}

final bandsProvider = StreamProvider<List<Band>>((ref) {
  return FirebaseFirestore.instance
      .collection('bands')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Band.fromDoc(doc)).toList());
});
