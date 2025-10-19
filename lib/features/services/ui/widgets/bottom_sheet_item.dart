// lib/features/services/ui/widgets/bottom_sheet_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

class BottomSheetItem extends StatelessWidget {
  final String title;
  final String image;
  final void Function()? onTap;
  const BottomSheetItem({
    super.key,
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.darkGray.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FittedBox(
          child: Column(
            children: [
              // الدائرة الزرقاء المصمتة
              Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorsManager.primaryColor,
                ),
              ),
              verticalSpace(8),
              Text(
                title,
                style: TextStyles.font18Black500Weight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}