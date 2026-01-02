import 'package:flutter/material.dart';

class BioTab extends StatelessWidget {
  final String imagePath;

  const BioTab({super.key, required this.imagePath});

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
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
          ),

          const SizedBox(height: 60),

       const Center(
            child: Text(
            '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
