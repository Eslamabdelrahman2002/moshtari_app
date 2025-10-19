// lib/core/widgets/reminder.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class Reminder extends StatelessWidget {
  const Reminder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ✅ بدل عرض ثابت
      constraints: BoxConstraints(minHeight: 40.h), // ✅ مرونة ارتفاع
      decoration: BoxDecoration(
        color: ColorsManager.secondary50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const MySvg(image: 'lamp_charge', width: 24, height: 24),
          // SizedBox(width: 6.w),
          Expanded(
            child: Text(
              'التواصل عبر الرسائل الخاصة بالتطبيق يحفظ الحقوق ويقلل الاحتيال.',
              style: TextStyles.font12Black500Weight,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}