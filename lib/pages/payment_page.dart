import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';
import 'package:go_router/go_router.dart';

class PaymentPage extends HookConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartCtrl = ref.read(cartProvider.notifier);
    final total = cartCtrl.total;

    // 🔹 入力コントローラ
    final postalCtrl = useTextEditingController();
    final address1Ctrl = useTextEditingController();
    final address2Ctrl = useTextEditingController();
    final phoneCtrl = useTextEditingController();

    // 🔹 支払い方法
    final selectedMethod = useState<String>('credit');

    // 🔹 Firestoreから既存の住所情報を読み込み
    useEffect(() {
      Future(() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data();
        if (data != null) {
          postalCtrl.text = (data['postal'] ?? '') as String;
          address1Ctrl.text =
          (data['address1'] ?? data['address'] ?? '') as String;
          address2Ctrl.text = (data['address2'] ?? '') as String;
          phoneCtrl.text =
          (data['phone'] ?? data['mobilePhone'] ?? '') as String;
        }
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('支払い方法'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: cart.isEmpty
          ? const Center(
        child: Text(
          'カートが空です 🛒',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '配送先情報',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: postalCtrl,
              decoration: const InputDecoration(
                labelText: '郵便番号',
                border: OutlineInputBorder(),
                hintText: '例）123-4567',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: address1Ctrl,
              decoration: const InputDecoration(
                labelText: '住所（都道府県・市区町村）',
                border: OutlineInputBorder(),
                hintText: '例）東京都渋谷区〇〇',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: address2Ctrl,
              decoration: const InputDecoration(
                labelText: '建物名・部屋番号',
                border: OutlineInputBorder(),
                hintText: '例）〇〇ビル101',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: '電話番号',
                border: OutlineInputBorder(),
                hintText: '例）09012345678',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            const Text(
              '支払い方法を選択',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('クレジットカード'),
              value: 'credit',
              groupValue: selectedMethod.value,
              onChanged: (v) => selectedMethod.value = v!,
            ),
            RadioListTile<String>(
              title: const Text('コンビニ払い'),
              value: 'conbini',
              groupValue: selectedMethod.value,
              onChanged: (v) => selectedMethod.value = v!,
            ),
            RadioListTile<String>(
              title: const Text('PayPay'),
              value: 'paypay',
              groupValue: selectedMethod.value,
              onChanged: (v) => selectedMethod.value = v!,
            ),
            const Spacer(),

            // 🔹 合計と確定ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '合計: ¥$total',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    '支払いを確定する',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) =>
                          AlertDialog(
                            title: const Text('支払いを確定しますか？'),
                            content:
                            const Text('購入内容を確認のうえ「はい」を押してください。'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('キャンセル'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: const Text('はい'),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      await _completePayment(
                        context,
                        ref,
                        selectedMethod.value,
                        postalCtrl.text,
                        address1Ctrl.text,
                        address2Ctrl.text,
                        phoneCtrl.text,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Firestore 登録
  /// 🔹 Firestore 登録
  Future<void> _completePayment(BuildContext context,
      WidgetRef ref,
      String method,
      String postal,
      String address1,
      String address2,
      String phone,) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カートが空です')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;

    try {
      // 🔸 ユーザー情報に住所を保存
      await firestore.collection('users').doc(user.uid).set({
        'postal': postal,
        'address1': address1,
        'address2': address2,
        'phone': phone,
      }, SetOptions(merge: true));

      // 🔸 購入履歴に商品情報＋住所情報を保存
      String? orderId;

      for (final item in cart) {
        // ✅ 数量と合計金額を計算
        final quantity = item.quantity;
        final totalPrice = item.price * quantity;

        final doc = await firestore.collection('goods_history').add({
          'userId': user.uid,
          'productId': item.id ?? '',
          'name': item.name,
          'price': item.price,
          'quantity': quantity, // 🆕 追加
          'totalPrice': totalPrice, // 🆕 追加
          'date': FieldValue.serverTimestamp(),
          'paymentMethod': method,
          'imageUrl': '',
          'postal': postal,
          'address1': address1,
          'address2': address2,
          'phone': phone,
        });

        orderId = doc.id;
      }

      // ✅ カートを空にする
      ref.read(cartProvider.notifier).clear();

      if (context.mounted && orderId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('支払いが完了しました 🎉')),
        );
        context.go('/purchase-complete', extra: orderId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('購入に失敗しました: $e')),
      );
    }
  }
}
