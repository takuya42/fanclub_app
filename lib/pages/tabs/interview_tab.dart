import 'package:flutter/material.dart';

class InterviewTabContent extends StatelessWidget {
  const InterviewTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text('インタビュー #${index + 1}'),
            subtitle: const Text('インタビューの内容がここに入ります'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}
