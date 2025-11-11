import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CarPrice extends StatelessWidget {
  final double? price;
  const CarPrice({super.key, this.price});

  String _formatPrice(BuildContext context, double? v) {
    if (v == null) return 'غير محدد';
    final bool rtl = Directionality.of(context) == TextDirection.RTL;
    final f = NumberFormat.decimalPattern(rtl ? 'ar' : 'en')
      ..maximumFractionDigits = (v % 1 == 0) ? 0 : 2;
    return f.format(v);
  }

  @override
  Widget build(BuildContext context) {
    final txt = _formatPrice(context, price);
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
          Text(txt, style: TextStyles.font24Primary500Weight),
          SizedBox(width: 6.w),
          MySvg(image: 'saudi_riyal', width: 24.w),
        ],
      ),
    );
  }
}