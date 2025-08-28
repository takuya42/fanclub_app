import 'package:flutter/material.dart';

class ShakilamoPage extends StatelessWidget {
  const ShakilamoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHAKILAMO'),
      ),
      body: const Center(
        child: Text(
          'SHAKILAMO（シャキラモ）についての紹介ページです。',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
