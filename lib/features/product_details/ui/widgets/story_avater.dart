import 'dart:math' as math;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoryAvater extends StatelessWidget {
  final double radius;               // نصف قطر الصورة
  final String? coverImageUrl;       // صورة الغلاف
  final List<Color> segmentColors;   // ألوان القطاعات
  final VoidCallback onTap;

  const StoryAvater({
    super.key,
    required this.radius,
    required this.coverImageUrl,
    required this.segmentColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final outerR = radius + 3; // مسافة خارجية للحلقة
    final circumference = 2 * math.pi * outerR;
    final n = segmentColors.length;
    final gapAngleDeg = 12.0;
    final gapPx = circumference * (gapAngleDeg / 360.0);
    final segPx = (circumference - n * gapPx) / (n == 0 ? 1 : n);
    final diameter = (radius * 2) + (3 * 2);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (n == 0)
              _ring(circumference, segPx: circumference, color: Colors.grey.shade300)
            else
              for (int i = 0; i < n; i++)
                Transform.rotate(
                  angle: _angleForIndex(i, segPx, gapPx, circumference, startAngleDeg: -90),
                  child: _ring(circumference, segPx: segPx, color: segmentColors[i]),
                ),
            GestureDetector(
              onTap: onTap,
              child: ClipOval(
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: Colors.grey.shade200,
                  child: coverImageUrl != null && coverImageUrl!.isNotEmpty
                      ? Image.network(
                    coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.collections_outlined, color: Colors.grey),
                  )
                      : const Icon(Icons.collections_outlined, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(double circumference, {required double segPx, required Color color}) {
    return DottedBorder(
      borderType: BorderType.Circle,
      color: color,
      strokeWidth: 2,
      dashPattern: [
        segPx.clamp(1, circumference),
        (circumference - segPx).clamp(0, circumference),
      ],
      padding: EdgeInsets.all(3),
      child: SizedBox(width: radius * 2, height: radius * 2),
    );
  }

  double _angleForIndex(
      int i,
      double segPx,
      double gapPx,
      double circumference, {
        double startAngleDeg = -90,
      }) {
    final fraction = (i * (segPx + gapPx)) / circumference;
    final base = fraction * 2 * math.pi;
    return base + (startAngleDeg * math.pi / 180.0);
  }
}