import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class HighestAuction extends StatelessWidget {
  const HighestAuction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.w,
      width: 170.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ColorsManager.blueGradient1,
            ColorsManager.blueGradient2,
          ],
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'اعلى سوم',
              style: TextStyles.font12White400Weight.copyWith(height: 0.6),
            ),
            horizontalSpace(2),
            MySvg(image: 'send', width: 12.w, height: 12.w),
            const Spacer(),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(
                  '552,223',
                  style: TextStyles.font12White500Weight.copyWith(height: 0.9),
                ),
              ),
            ),
            horizontalSpace(4),
            MySvg(image: 'riyal_new', width: 12.w, height: 12.w),
          ],
        ),
      ),
    );
  }
}
