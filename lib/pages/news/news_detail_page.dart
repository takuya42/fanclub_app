import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key, this.id = '', this.title});
  final String id;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('お知らせ詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $id', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Title: ${title ?? "(未指定)"}'),
          ],
        ),
      ),
    );
  }
}
