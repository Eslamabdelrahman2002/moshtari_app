import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';

class StoryAvater extends StatelessWidget {
  StoryAvater({super.key});

  final List status = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 15, 20, 30, 40, 80];
  final double radius = 30;
  final index = 6;

  double colorWidth(double radius, int statusCount, double separation) {
    return ((2 * pi * radius) - (statusCount * separation)) / statusCount;
  }

  double separation(int statusCount) {
    if (statusCount <= 20) {
      return 3.0;
    } else if (statusCount <= 30) {
      return 1.8;
    } else if (statusCount <= 60) {
      return 1.0;
    } else {
      return 0.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: DottedBorder(
        borderType: BorderType.Circle,
        color: ColorsManager.primaryColor,
        strokeWidth: 2,
        dashPattern: status[index] == 1
            ? [
                (2 * pi * (radius + 2)),
                0,
              ]
            : [
                colorWidth(
                    radius + 2, status[index], separation(status[index])),
                separation(status[index]),
              ],
        padding: const EdgeInsets.all(3),
        child: CircleAvatar(
          radius: radius.r,
          backgroundImage: const AssetImage('assets/images/img.png'),
        ),
      ),
    );
  }
}
