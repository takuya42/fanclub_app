import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/cart_provider.dart';

class ShopTab extends ConsumerStatefulWidget {
  const ShopTab({super.key});

  @override
  ConsumerState<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends ConsumerState<ShopTab> {
  bool isLoading = true;
  String? errorMessage;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> goodsList = [];

  @override
  void initState() {
    super.initState();
    fetchGoods();
  }

  /// 🔹 Firestoreからデータを一度だけ取得（キャッシュ優先）
  Future<void> fetchGoods() async {
    setState(() => isLoading = true);
    try {
      // 🔸 キャッシュから読み込み（オフライン対応）
      final cached = await FirebaseFirestore.instance
          .collection('goods')
          .get(const GetOptions(source: Source.cache));

      if (cached.docs.isNotEmpty) {
        setState(() => goodsList = cached.docs);
      }

      // 🔸 サーバーから最新データを再取得
      final snapshot = await FirebaseFirestore.instance
          .collection('goods')
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));

      setState(() {
        goodsList = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'データの取得に失敗しました: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartCtrl = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'グッズ一覧',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      /// 🔹 Firestoreのfetch結果を表示
      body: RefreshIndicator( // ← 下にスワイプで再取得
        onRefresh: fetchGoods,
        child: Builder(
          builder: (context) {
            if (isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent));
            }

            if (errorMessage != null) {
              return Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (goodsList.isEmpty) {
              return const Center(
                child: Text('現在、商品は登録されていません。',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: goodsList.length,
              itemBuilder: (context, index) {
                final doc = goodsList[index];
                final data = doc.data();
                final id = doc.id;
                final name = data['name'] ?? '商品名なし';
                final price = data['price'] ?? 0;
                final imageUrl = data['imageUrl'] ?? '';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 商品画像
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text(
                                '商品画像',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 商品名と価格
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          '¥$price',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),

                      // 「カートに追加」ボタン
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            cartCtrl.addItem(
                                CartItem(id: id, name: name, price: price));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('「$name」をカートに追加しました')),
                            );
                          },
                          child: const Text('カートに追加'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
