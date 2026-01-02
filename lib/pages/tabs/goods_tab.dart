import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

class GoodsTabContent extends StatefulWidget {
  const GoodsTabContent({super.key});

  @override
  State<GoodsTabContent> createState() => _GoodsTabContentState();
}

class _GoodsTabContentState extends State<GoodsTabContent> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> goodsList = [];

  @override
  void initState() {
    super.initState();
    fetchGoods();
  }

  /// 🔹 Firestoreからデータを一度だけ取得（キャッシュ優先）
  Future<void> fetchGoods() async {
    try {
      // まずキャッシュから読み込む
      final cachedSnapshot = await FirebaseFirestore.instance
          .collection('goods')
          .get(const GetOptions(source: Source.cache));

      if (cachedSnapshot.docs.isNotEmpty) {
        setState(() {
          goodsList = cachedSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'name': data['name'] ?? '商品名なし',
              'price': data['price'] ?? 0,
              'imageUrl': data['imageUrl'] ?? '',
              'isAvailable': data['isAvailable'] ?? true,
            };
          }).toList();
          isLoading = false;
        });
      }

      // 🔸 サーバーから最新データを取得してキャッシュ更新
      final serverSnapshot = await FirebaseFirestore.instance
          .collection('goods')
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));

      setState(() {
        goodsList = serverSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'name': data['name'] ?? '商品名なし',
            'price': data['price'] ?? 0,
            'imageUrl': data['imageUrl'] ?? '',
            'isAvailable': data['isAvailable'] ?? true,
          };
        }).toList();
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF111111)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // ✅ スクロール可能に変更
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 タイトル部分
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NEW GOODS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 6, bottom: 20),
                height: 3,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // 🔹 データ表示
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
                )
              else if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (goodsList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Text(
                      '現在、商品情報はありません。',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: goodsList.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, i) {
                      final data = goodsList[i];
                      final name = data['name'];
                      final price = data['price'];
                      final imageUrl = data['imageUrl'];
                      final isAvailable = data['isAvailable'];

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 🔹 商品画像
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, _) =>
                                      const Icon(
                                        Icons.broken_image,
                                        color: Colors.white30,
                                        size: 40,
                                      ),
                                    )
                                        : Container(
                                      color: Colors.black12,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white30,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      if (!isAvailable)
                                        const Text(
                                          '準備中です',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      else
                                        Text(
                                          '¥$price',
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

              // 🔹 ここが確実に表示される
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => context.push('/shop'),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text(
                  'すべてのグッズを見る',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
