import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/mypage_palette.dart';

/// ────────────────────────────────
/// モデルクラス
/// ────────────────────────────────
class GoodsItem {
  final String id;
  final String name;
  final int price;
  final int quantity;
  final int totalPrice;
  final DateTime date;
  final String? imageUrl;
  final String? productId;
  final String? postal;
  final String? address1;
  final String? address2;
  final String? phone;

  GoodsItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.date,
    this.imageUrl,
    this.productId,
    this.postal,
    this.address1,
    this.address2,
    this.phone,
  });

  factory GoodsItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final price = _toInt(data['price']);
    final qty = _toInt(data['quantity'], defaultValue: 1);
    final total = _toInt(data['totalPrice'], defaultValue: price * qty);

    return GoodsItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: price,
      quantity: qty,
      totalPrice: total,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      productId: data['productId'],
      postal: data['postal'],
      address1: data['address1'],
      address2: data['address2'],
      phone: data['phone'],
    );
  }

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}

/// ────────────────────────────────
/// Provider（Firestore購読）
/// ────────────────────────────────
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

/// ────────────────────────────────
/// ページ本体
/// ────────────────────────────────
class GoodsHistoryPage extends ConsumerWidget {
  const GoodsHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pal = MyPagePalette.fromBrightness(
      Theme.of(context).brightness == Brightness.dark,
    );

    final asyncGoods = ref.watch(goodsHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('グッズ購入履歴'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: pal.bg,
      body: asyncGoods.when(
        data: (goodsList) {
          if (goodsList.isEmpty) {
            return Center(
              child: Text(
                '購入履歴がありません',
                style: TextStyle(color: pal.muted, fontSize: 16),
              ),
            );
          }

          // 🔹 総支払額
          final totalSpent =
          goodsList.fold<int>(0, (sum, item) => sum + item.totalPrice);

          return Column(
            children: [
              // 🔸 上部 合計表示
              Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '総支払額：¥$totalSpent',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 🔸 リスト本体
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: goodsList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = goodsList[index];

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart, // ← 右→左スワイプで削除
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),


                      confirmDismiss: (direction) async {
                        // 🔸 確認ダイアログを出す
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('削除確認'),
                            content: Text('${item.name} を削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('キャンセル'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('削除'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        // 🔸 Firestoreから削除
                        await FirebaseFirestore.instance
                            .collection('goods_history')
                            .doc(item.id)
                            .delete();

                        // 🔸 メッセージ（今回は控えめに）
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} を削除しました'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: _goodsCard(context, item, pal),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () =>
        const Center(child: CircularProgressIndicator(color: Colors.grey)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '読み込みに失敗しました。\nFirestoreでインデックスを作成してください。\n\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  /// ────────────────────────────────
  /// 商品カードUI
  /// ────────────────────────────────
  Widget _goodsCard(BuildContext context, GoodsItem item, MyPagePalette pal) {
    return Container(
      decoration: BoxDecoration(
        color: pal.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pal.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─ 商品情報 ─
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : const Placeholder(strokeWidth: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏷 商品名
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 💰 単価 × 数量 = 合計金額
                      Text(
                        '¥${item.price} × ${item.quantity} = ¥${item.totalPrice}',
                        style: TextStyle(
                          color: pal.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 商品番号
                      Text(
                        '商品番号：${item.productId ?? '-'}',
                        style: TextStyle(color: pal.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 4),

                      // 購入日
                      Text(
                        '購入日：${_formatDate(item.date)}',
                        style: TextStyle(color: pal.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 日付フォーマット
  String _formatDate(DateTime date) =>
      '${date.year}/${date.month}/${date.day}';
}
