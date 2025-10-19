// lib/features/car_details/ui/widgets/car_story_and_title.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class CarStoryAndTitle extends StatelessWidget {
  final String title;
  const CarStoryAndTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Text(
        title,
        style: TextStyles.font20Black500Weight,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}