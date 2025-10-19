import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';

class StarsRate extends StatelessWidget {
  final double rate;
  const StarsRate({super.key, this.rate = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          rate >= 1 ? Icons.star_rounded : Icons.star_border_rounded,
          color: ColorsManager.secondary500,
          size: 16.w,
        ),
        Icon(
          rate >= 2 ? Icons.star_rounded : Icons.star_border_rounded,
          color: ColorsManager.secondary500,
          size: 16.w,
        ),
        Icon(
          rate >= 3 ? Icons.star_rounded : Icons.star_border_rounded,
          color: ColorsManager.secondary500,
          size: 16.w,
        ),
        Icon(
          rate >= 4 ? Icons.star_rounded : Icons.star_border_rounded,
          color: ColorsManager.secondary500,
          size: 16.w,
        ),
        Icon(
          rate >= 5 ? Icons.star_rounded : Icons.star_border_rounded,
          color: ColorsManager.secondary500,
          size: 16.w,
        ),
      ],
    );
  }
}
