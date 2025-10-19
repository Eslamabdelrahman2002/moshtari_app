import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class HighestAuction extends StatelessWidget {
  final String highestAuction;
  const HighestAuction({
    super.key,
    required this.highestAuction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      width: 358.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ColorsManager.blueGradient1,
            ColorsManager.blueGradient2,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'اعلى سوم',
              style: TextStyles.font12Primary100400Weight,
            ),
            horizontalSpace(2),
            const MySvg(image: 'send'),
            const Spacer(),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(
                  highestAuction,
                  style: TextStyles.font24White500Weight,
                ),
              ),
            ),
            horizontalSpace(4),
            MySvg(image: 'riyal_onblue', width: 24.w, height: 24.h),
          ],
        ),
      ),
    );
  }
}
