import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class RealEstateChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onSelect;
  const RealEstateChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        height: 32.h,
        decoration: BoxDecoration(
          color:
              isSelected ? ColorsManager.primary400 : ColorsManager.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? ColorsManager.white : ColorsManager.darkGray400,
            fontSize: TextStyles.fontSize(14),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
