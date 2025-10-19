import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstateDropDown extends StatelessWidget {
  final String title;
  const RealEstateDropDown({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 120.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      decoration: BoxDecoration(
        color: ColorsManager.secondary50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MySvg(image: 'arrow-down', width: 12.w, height: 12.w),
          horizontalSpace(4),
          SizedBox(
            width: 50.w,
            child: Center(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: TextStyles.fontSize(12),
                  color: ColorsManager.secondary900,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          horizontalSpace(4),
          MySvg(image: 'location-darkyellow', width: 12.w, height: 12.w),
        ],
      ),
    );
  }
}
