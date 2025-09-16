import 'dart:async';
import 'package:flutter/material.dart';
import '../pages/shakilamo_page.dart'; // ※パスはあなたの構成に合わせて調整

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  final List<String> images = [
    'assets/images/SHAKILAMO_profile.JPG',
    'assets/images/SHAKILAMO.JPG',
  ];

  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          return GestureDetector(
            onTap: () {
              if (image == 'assets/images/SHAKILAMO.JPG') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShakilamoPage(imagePath: image),
                  ),
                );
              }
            },
            child: Image.asset(image, fit: BoxFit.cover, width: double.infinity),
          );
        },
      ),
    );
  }
}
