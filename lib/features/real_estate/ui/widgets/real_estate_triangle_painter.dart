import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';

class RealEstateTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = ColorsManager.secondary500
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(size.width / 2, 0); // Top center of the container
    path.lineTo(0, size.height); // Bottom left corner of the container
    path.lineTo(
        size.width, size.height); // Bottom right corner of the container
    path.close(); // Uses lineTo to close the path back at the starting point

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
