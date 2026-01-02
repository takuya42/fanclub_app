import 'package:flutter/material.dart';
import 'package:fanclub_app/pages/news/news_from_sheet.dart'; // ← スプレッドシート or Firestore対応

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📰 LATEST NEWS セクション
          const Text(
            'LATEST NEWS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
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

          // 🔹 ニュース一覧（スプレッドシート or Firestore）
          const NewsFromSheet(), // ← スプレッドシートを読み込むWidget

          const SizedBox(height: 60),

          // 🎸 ARTIST セクション
          const Text(
            'ARTIST',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 30),
            height: 3,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/shakilamo_logo.png',
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          const Center(
            child: Text(
              'SHAKILAMO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),




        ],
      ),
    );
  }
}
