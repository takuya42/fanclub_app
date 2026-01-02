import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteItem {
  final String id;
  final String name;
  final String? imageUrl;
  const FavoriteItem({required this.id, required this.name, this.imageUrl});
}

class FavoritesController extends StateNotifier<List<FavoriteItem>> {
  FavoritesController() : super(const []);

  bool isFavorite(String id) => state.any((e) => e.id == id);

  void add(FavoriteItem item) {
    if (!isFavorite(item.id)) {
      state = [...state, item];
    }
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final favoritesProvider =
StateNotifierProvider<FavoritesController, List<FavoriteItem>>(
      (ref) => FavoritesController(),
);
