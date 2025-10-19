import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class UserTag extends StatelessWidget {
  final String bargainPrice;
  const UserTag({
    super.key,
    required this.bargainPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Row(
        children: [
          Text(
            'يسوم $bargainPrice',
            style: TextStyles.font12Blue400Weight,
          ),
          horizontalSpace(4),
          MySvg(
            image: 'riyal_blue',
            width: 16.w,
            height: 16.w,
          ),
        ],
      ),
    );
  }
}
