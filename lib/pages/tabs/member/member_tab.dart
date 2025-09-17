import 'package:flutter/material.dart';

class MemberTab extends StatelessWidget {
  const MemberTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // メンバー数
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左側：写真
              Container(
                width: 100,
                height: 120,
                color: Colors.grey[300],
                child: const Center(child: Text('写真')),
              ),
              const SizedBox(width: 16),

              // 右側：プロフィール
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('名前：○○○○'),
                    Text('誕生日：199X年X月X日'),
                    Text('血液型：A型'),
                    Text('特技：ドラム、料理'),
                    Text('好きなもの：カレー、猫'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
