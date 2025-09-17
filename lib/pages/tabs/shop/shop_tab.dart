// shop_tab.dart
import 'package:flutter/material.dart';

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3列
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 9, // 商品数
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Text('商品画像')),
              ),
            ),
            const SizedBox(height: 4),
            const Text('商品名'),
            const Text('¥2,000'),
          ],
        );
      },
    );
  }
}
