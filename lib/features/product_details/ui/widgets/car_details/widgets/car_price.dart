// lib/features/car_details/ui/widgets/car_price.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CarPrice extends StatelessWidget {
  final double? price;
  const CarPrice({super.key, this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      width: 358.w,
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Text("السعر:", style: TextStyles.font14Primary300500Weight),
          const Spacer(),
          Text(
            price != null ? price!.toStringAsFixed(0) : "غير محدد",
            style: TextStyles.font24Primary500Weight,
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: MySvg(image: 'saudi_riyal', width: 24.w)),
        ],
      ),
    );
  }
}