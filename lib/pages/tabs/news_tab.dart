import 'package:flutter/material.dart';

class NewsTabContent extends StatelessWidget {
  const NewsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final newsList = List.generate(5, (i) => {
      'artist': 'アーティスト${i + 1}',
      'date': '8月${i + 1}日(金)',
      'event': 'Zepp Nagoya ワンマンライブ開催決定！',
    });

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: newsList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final news = newsList[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Center(child: Text('サムネ')),
            ),
            title: Text('<${news['artist']}>'),
            subtitle: Text('${news['date']} ${news['event']}'),
          ),
        );
      },
    );
  }
}
