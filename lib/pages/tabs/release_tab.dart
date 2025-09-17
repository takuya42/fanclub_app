import 'package:flutter/material.dart';

class ReleaseTabContent extends StatelessWidget {
  const ReleaseTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final releaseList = List.generate(5, (i) => {
      'artist': 'アーティスト名 / タイトル',
      'date': '2025.8.${i + 1}日(○)　RELEASE',
      'music': '【収録曲】01   02   03   04  ',
    });


    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: releaseList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final release = releaseList[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Center(child: Text('ジャケットサムネイル')),
            ),
            title: Text('<${release['artist']}>'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${release['date']}'),
                Text('${release['music']}'),
              ],
            ),
          ),
        );
      },
    );
  }
}