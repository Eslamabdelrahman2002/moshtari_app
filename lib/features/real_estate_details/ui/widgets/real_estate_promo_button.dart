// lib/features/real_estate_details/ui/widgets/real_estate_promo_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class PromoButton extends StatelessWidget {
  // ✅ سيتم ربط الـ onPressed الخاص به بـ Marketing Sheet في الشاشة الرئيسية
  final VoidCallback? onPressed;
  const PromoButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            style: ButtonStyle(
                elevation: WidgetStateProperty.all(0),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                backgroundColor:
                WidgetStateProperty.all(ColorsManager.primary50),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                )),
            onPressed: onPressed, // ✅ ربط الـ onPressed هنا
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MySvg(image: 'loudspeaker', width: 16.w, height: 16.h),
                horizontalSpace(4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'سوق للأعلان',
                    style: TextStyles.font12Primary400400Weight,
                  ),
                ),
              ],
            )),
        verticalSpace(20),
      ],
    );
  }
}