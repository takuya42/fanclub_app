import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🛍️ カート内アイテム
class CartItem {
  final String id;
  final String name;
  final int price;
  final int quantity; // ← 数量追加

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1, // デフォルト1
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// 🧮 カートの管理クラス
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// 🛒 カートに商品を追加
  void addItem(CartItem item) {
    final index = state.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      // すでに存在 → 数量を+1
      final updated = state[index].copyWith(
        quantity: state[index].quantity + 1,
      );
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) updated else state[i],
      ];
    } else {
      // 新規商品
      state = [...state, item];
    }
  }

  /// ➖ 数量を減らす（1なら削除）
  void decreaseItem(String id) {
    final index = state.indexWhere((e) => e.id == id);
    if (index != -1) {
      final current = state[index];
      if (current.quantity > 1) {
        final updated = current.copyWith(quantity: current.quantity - 1);
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index) updated else state[i],
        ];
      } else {
        removeItem(id);
      }
    }
  }

  /// ❌ 商品削除
  void removeItem(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  /// 🧹 カートを空に
  void clear() => state = [];

  /// 💴 合計金額
  int get total =>
      state.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

/// 🔸 Provider 本体
final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
