import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class ColoredDottedStoryRing extends StatelessWidget {
  final double radius;               // نصف قطر الصورة (CircleAvatar)
  final ImageProvider image;         // صورة الوسط
  final List<Color> segmentColors;   // لون كل قطاع في الحلقة
  final double strokeWidth;          // سمك الحلقة
  final double borderPadding;        // مسافة بين الصورة والحد (مثل padding في DottedBorder)
  final double gapAngleDeg;          // درجة الفراغ بين القطاعات
  final double startAngleDeg;        // دوران البداية (0 = يمين، -90 = أعلى)
  final VoidCallback? onTap;

  const ColoredDottedStoryRing({
    super.key,
    required this.radius,
    required this.image,
    required this.segmentColors,
    this.strokeWidth = 2.5,
    this.borderPadding = 3,
    this.gapAngleDeg = 10,
    this.startAngleDeg = -90, // يبدأ من الأعلى مثل قصص إنستغرام
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (segmentColors.isEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: image);
    }

    final double outerR = radius + borderPadding; // نصف قطر مسار الحلقة
    final double circumference = 2 * math.pi * outerR;
    final int n = segmentColors.length;

    // حوّل gapAngleDeg إلى طول بالبيكسل على المسار
    final double gapPx = circumference * (gapAngleDeg / 360.0);
    // طول الجزء الملون لكل قطاع
    final double segPx = (circumference - n * gapPx) / n;

    final double diameter = (radius * 2) + (borderPadding * 2);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الحلقات الملوّنة (كل حلقة = شرطة واحدة ملوّنة)
          for (int i = 0; i < n; i++)
            Transform.rotate(
              angle: _angleForIndex(
                i: i,
                segPx: segPx,
                gapPx: gapPx,
                circumference: circumference,
                startAngleDeg: startAngleDeg,
              ),
              child: DottedBorder(
                borderType: BorderType.Circle,
                color: segmentColors[i],
                strokeWidth: strokeWidth,
                dashPattern: [
                  segPx.clamp(1, circumference), // طول الجزء الملوّن
                  (circumference - segPx).clamp(0, circumference), // الباقي فراغ
                ],
                padding: EdgeInsets.all(borderPadding),
                child: SizedBox(
                  width: radius * 2,
                  height: radius * 2,
                ),
              ),
            ),

          // الصورة في الوسط (مرسومة مرة واحدة فوق الحلقات)
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: radius,
              backgroundImage: image,
            ),
          ),
        ],
      ),
    );
  }

  double _angleForIndex({
    required int i,
    required double segPx,
    required double gapPx,
    required double circumference,
    required double startAngleDeg,
  }) {
    // نوزّع القطاعات بالتساوي: (طول القطاع + طول الفراغ) كنسبة من المحيط -> زاوية
    final double fraction = (i * (segPx + gapPx)) / circumference;
    final double baseAngle = fraction * 2 * math.pi;
    final double startRad = startAngleDeg * math.pi / 180.0;
    return baseAngle + startRad;
  }
}