import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class RealEstateFilteringChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const RealEstateFilteringChip({
    super.key,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
        height: 32.h,
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primary50 : ColorsManager.dark50,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color:
                isSelected ? ColorsManager.primary500 : ColorsManager.dark100,
            width: 1.w,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? ColorsManager.primary500
                : ColorsManager.darkGray400,
            fontSize: TextStyles.fontSize(12),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
