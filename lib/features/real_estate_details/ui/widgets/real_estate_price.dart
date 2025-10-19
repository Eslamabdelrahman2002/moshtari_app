import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/currency_extension.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstatePrice extends StatelessWidget {
  // Added the 'price' parameter to accept data.
  final num? price;

  const RealEstatePrice({super.key, this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      width: 358.w,
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'السعر:',
              style: TextStyles.font14Primary300500Weight,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(
                  // The widget now displays the price it receives.
                  price != null ? price!.toStringAsFixed(0) : "غير محدد",   // أو باستخدام toCurrency()
                  style: TextStyles.font24Primary500Weight,
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
