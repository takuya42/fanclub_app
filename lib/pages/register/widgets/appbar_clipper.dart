// lib/pages/auth/widgets/appbar_clipper.dart
import 'package:flutter/widgets.dart';

class CustomAppBarClipper extends CustomClipper<Path> {
  const CustomAppBarClipper();

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 30)
      ..quadraticBezierTo(
          size.width / 2, size.height + 30, size.width, size.height - 30)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomAppBarClipper oldClipper) => true;
}
