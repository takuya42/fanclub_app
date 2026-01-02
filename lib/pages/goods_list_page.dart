import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';


class GoodsListPage extends StatefulWidget {
  const GoodsListPage({super.key});

  @override
  State<GoodsListPage> createState() => _GoodsListPageState();
}

class _GoodsListPageState extends State<GoodsListPage> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> goodsList = [];

  @override
  void initState() {
    super.initState();
    fetchGoods();
  }

  Future<void> fetchGoods() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('goods')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        goodsList = snapshot.docs.map((doc) {
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
        errorMessage = 'データ取得に失敗しました: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _buyItem(BuildContext context, String name, int price) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('goods_history').add({
        'userId': user.uid,
        'name': name,
        'price': price,
        'date': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('「$name」を購入しました')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('購入に失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      /// 🔥 ここにカートアイコンを追加
      appBar: AppBar(
        title: const Text('グッズ一覧'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, size: 26),
            onPressed: () {
              context.push('/cart');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.white70),
        ),
      )
          : goodsList.isEmpty
          ? const Center(
        child: Text(
          '現在、公開中のグッズはありません。',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goodsList.length,
        itemBuilder: (context, i) {
          final item = goodsList[i];
          final name = item['name'];
          final price = item['price'];
          final imageUrl = item['imageUrl'];
          final isAvailable = item['isAvailable'];

          return Card(
            color: Colors.white12,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image,
                      color: Colors.white30),
                )
                    : const Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.white30,
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isAvailable ? '¥$price' : '販売停止中',
                style: TextStyle(
                  color: isAvailable
                      ? Colors.redAccent
                      : Colors.grey,
                ),
              ),
              trailing: isAvailable
                  ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    _buyItem(context, name, price),
                child: const Text('購入'),
              )
                  : const Text(
                '販売停止中',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
