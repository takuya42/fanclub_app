import 'package:flutter/material.dart';

class PickUpTabContent extends StatelessWidget {
  const PickUpTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PICK UP ARTIST <vol.1>',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // アーティスト写真
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text('アーティスト写真')),
          ),

          const SizedBox(height: 16),

          // アーティスト名やロゴ
          const Center(
            child: Text(
              'アーティスト名 or ロゴ\n(L - R : Vo. / Dr. / Ba. / Gt.)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            '紹介文',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'このアーティストは、○○年に結成され...\n最新の活動内容や魅力を紹介します。',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
