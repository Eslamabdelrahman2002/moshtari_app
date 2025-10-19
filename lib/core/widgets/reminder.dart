import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class Reminder extends StatelessWidget {
  const Reminder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      height: 40.w,
      decoration: BoxDecoration(
        color: ColorsManager.secondary50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(8.w),
      child: Row(
        children: [
          MySvg(
            image: 'lamp_charge',
            width: 15.w,
            height: 15.w,
          ),
          horizontalSpace(4),
          Text(
            'التواصل عبر الرسائل الخاصة بالتطبيق يحفظ الحقوق ويقلل الاحتيال.',
            style: TextStyles.font12Black400Weight,
          ),
        ],
      ),
    );
  }
}
