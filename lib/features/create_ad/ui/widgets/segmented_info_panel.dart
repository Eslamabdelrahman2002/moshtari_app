import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class SegmentedInfoPanel extends StatelessWidget {
  const SegmentedInfoPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: ColorsManager.grey100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15.5),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'التصنيف',
                      style: TextStyles.font16Dark500400Weight,
                    ),
                    verticalSpace(16),
                    Row(
                      children: [
                        MySvg(image: 'car', width: 16.w, height: 16.h),
                        horizontalSpace(11),
                        Text(
                          'سيارات',
                          style: TextStyles.font16Primary500400Weight,
                        )
                      ],
                    ),
                  ],
                ),
                VDivider(39.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الموديل',
                      style: TextStyles.font16Dark500400Weight,
                    ),
                    verticalSpace(16),
                    Row(
                      children: [
                        // const MySvg(image: 'add', width: 16.w, height: 16.h),
                        horizontalSpace(11),
                        Text(
                          'جوك',
                          style: TextStyles.font16Primary500400Weight,
                        )
                      ],
                    ),
                  ],
                ),
                VDivider(39.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الماركة',
                      style: TextStyles.font16Dark500400Weight,
                    ),
                    verticalSpace(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MySvg(image: 'nissan', width: 16.w, height: 16.h),
                        horizontalSpace(11),
                        Text(
                          'نيسان',
                          style: TextStyles.font16Primary500400Weight,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            verticalSpace(24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'السنة',
                      style: TextStyles.font16Dark500400Weight,
                    ),
                    verticalSpace(16),
                    Row(
                      children: [
                        Text(
                          '2024',
                          style: TextStyles.font16Primary500400Weight,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
