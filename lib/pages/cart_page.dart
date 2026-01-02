import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartCtrl = ref.read(cartProvider.notifier);
    final total = cartCtrl.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('カート'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      // 🛒 カート内
      body: cart.isEmpty
          ? const Center(
        child: Text(
          'カートは空です 🛒',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cart.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = cart[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListTile(
              leading: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.black),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text('¥${item.price} × ${item.quantity}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () => cartCtrl.decreaseItem(item.id),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.green),
                    onPressed: () => cartCtrl.addItem(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // 🔹 下部合計と購入ボタン
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '合計: ¥$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: cart.isEmpty
                    ? null
                    : () {
                  // 支払い画面に遷移
                  context.push('/payment');
                },
                child: const Text(
                  '支払い画面へ進む',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔸 Firestore 購入処理（必要なら呼び出し用）
  Future<void> _saveToHistory(BuildContext context, WidgetRef ref) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }

    final cart = ref.read(cartProvider);
    final firestore = FirebaseFirestore.instance;

    try {
      for (final item in cart) {
        await firestore.collection('goods_history').add({
          'userId': user.uid,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity, // 🔥 数量を追加保存
          'date': FieldValue.serverTimestamp(),
        });
      }

      ref.read(cartProvider.notifier).clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('購入に失敗しました: $e')
        ),
      );
    }
  }
}
