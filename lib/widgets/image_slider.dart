import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  const ImageSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      'assets/images/SHAKILAMO_アー写.jpg',
    ];

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.asset(images[index], fit: BoxFit.cover);
        },
      ),
    );
  }
}
