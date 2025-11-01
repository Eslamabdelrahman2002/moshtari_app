import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/currency_extension.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstatePrice extends StatelessWidget {
  // يدعم رقم أو نص
  final dynamic price;

  const RealEstatePrice({super.key, this.price});

  String _formatPrice(dynamic p) {
    if (p == null) return 'غير محدد';
    if (p is num) {
      try {
        // لو عندك toCurrency() اشتغل به، وإلا fallback
        return p.toCurrency();
      } catch (_) {
        return p.toStringAsFixed(0);
      }
    }
    if (p is String) {
      final v = num.tryParse(p);
      if (v != null) {
        try {
          return v.toCurrency();
        } catch (_) {
          return v.toStringAsFixed(0);
        }
      }
      return p; // نص كما هو (مثلاً "حسب الاتفاق")
    }
    return p.toString();
  }

  @override
  Widget build(BuildContext context) {
    final display = _formatPrice(price);
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
          children: [
            Text('السعر:', style: TextStyles.font14Primary300500Weight),
            const Spacer(),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(display, style: TextStyles.font24Primary500Weight),
              ),
            ),
            horizontalSpace(4),
            Align(
              alignment: Alignment.bottomCenter,
              child: MySvg(image: 'riyal_new', width: 24.w, height: 24.h),
            ),
          ],
        ),
      ),
    );
  }
}