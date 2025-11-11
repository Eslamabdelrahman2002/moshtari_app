import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CarPartPrice extends StatelessWidget {
  final String? priceText;
  const CarPartPrice({super.key, this.priceText});

  String _formatPrice(BuildContext context, String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'غير محدد';
    String s = raw.trim();
    const arabic = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    const latin = ['0','1','2','3','4','5','6','7','8','9'];
    for (int i = 0; i < arabic.length; i++) {
      s = s.replaceAll(arabic[i], latin[i]);
    }
    s = s
        .replaceAll('٬', '')
        .replaceAll(',', '')
        .replaceAll('٫', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    final num? v = num.tryParse(s);
    if (v == null) return 'غير محدد';
    final bool rtl = Directionality.of(context) == TextDirection.RTL;
    final f = NumberFormat.decimalPattern(rtl ? 'ar' : 'en')
      ..maximumFractionDigits = (v % 1 == 0) ? 0 : 2;
    return f.format(v);
  }
  @override
  Widget build(BuildContext context) {
    final formatted = _formatPrice(context, priceText);
    return Container(
      height: 48.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Text("السعر:", style: TextStyles.font14Primary300500Weight),
          const Spacer(),
          Text(formatted, style: TextStyles.font24Primary500Weight),
          SizedBox(width: 6.w),
          MySvg(image: 'saudi_riyal', width: 20.w, height: 20.w),
        ],
      ),
    );
  }
}