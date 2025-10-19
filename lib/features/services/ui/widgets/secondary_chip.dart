import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class SecondaryChip extends StatelessWidget {
  final String title;
  final bool? isSelected;
  final Function()? onTap;

  const SecondaryChip({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
        height: 35.h,
        decoration: BoxDecoration(
          color: isSelected! ? ColorsManager.primary50 : ColorsManager.dark50,
          border: Border.all(
            color:
                isSelected! ? ColorsManager.primary500 : ColorsManager.dark100,
            width: 1.0.w,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Baseline(
            baseline: 13.h,
            baselineType: TextBaseline.alphabetic,
            child: Text(
              title,
              style: isSelected!
                  ? TextStyles.font14White500Weight
                      .copyWith(color: ColorsManager.primary500)
                  : TextStyles.font14Black500Weight
                      .copyWith(color: ColorsManager.darkGray400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
