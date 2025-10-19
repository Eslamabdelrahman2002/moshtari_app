// lib/features/services/ui/widgets/dinat_list_view_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

class DinatListViewItem extends StatelessWidget {
  final bool isInGrid; // لو True، نقلل الهوامش ونضغط الـ Row
  const DinatListViewItem({super.key, this.isInGrid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isInGrid ? 0 : 16.w, // مهم جداً داخل Grid
        vertical: 8.w,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 4,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [السطر 33 تقريباً] — الهيدر: أفاتار + اسم + من/إلى
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32.h,
                        height: 32.h,
                        decoration: const BoxDecoration(
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.grey, width: 2),
                          ),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/prof.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      horizontalSpace(8),
                      Expanded(
                        child: Text(
                          'محمد السيد',
                          style: TextStyles.font14Black500Weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // مهم
                        ),
                      ),
                    ],
                  ),
                ),
                horizontalSpace(8),
                // خليها Flexible + Row بحجم محتوى صغير
                Flexible(
                  child: Container(
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: ColorsManager.secondary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // مهم جداً
                      children: [
                        Text(
                          'الرياض',
                          style: TextStyles.font12Black500Weight,
                          overflow: TextOverflow.ellipsis,
                        ),
                        horizontalSpace(6),
                        MySvg(image: 'fromto', width: 36.w, height: 14.h),
                        horizontalSpace(6),
                        Text(
                          'الرياض',
                          style: TextStyles.font12Black500Weight,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            verticalSpace(12),

            // [السطر 100 تقريباً] — التفاصيل: حجم + تاريخ | الوقت
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MySvg(image: 'tractor', width: 16.w, height: 16.h),
                          horizontalSpace(6),
                          Flexible(
                            child: Text(
                              'كبيرة',
                              style: TextStyles.font12Black500Weight,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(6),
                      Row(
                        children: [
                          MySvg(image: 'calendar', width: 16.w, height: 16.h),
                          horizontalSpace(6),
                          Expanded(
                            child: Text(
                              '16/05/2024',
                              style: TextStyles.font12Black500Weight,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                horizontalSpace(8),
                MySvg(image: 'clock', width: 16.w, height: 16.h),
                horizontalSpace(6),
                Flexible(
                  child: Text(
                    '12:50 مساء',
                    style: TextStyles.font12Black500Weight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            verticalSpace(12),
            PrimaryButton(
              height: 32.h,
              backgroundColor: ColorsManager.primary50,
              textColor: ColorsManager.primary500,
              text: 'طلب خدمة',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}