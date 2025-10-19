import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';

class RealEstateSegmentedInfoPanel extends StatelessWidget {
  final String category;
  final String city;
  final List<String> areas;

  const RealEstateSegmentedInfoPanel({
    super.key,
    required this.category,
    required this.city,
    required this.areas,
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
                // التصنيف
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('التصنيف',
                        style: TextStyles.font16Dark500400Weight),
                    verticalSpace(16),
                    Text(
                      category,
                      style: TextStyles.font16Primary500400Weight,
                    ),
                  ],
                ),
                VDivider(39.h),

                // المدينة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('المدينه',
                        style: TextStyles.font16Dark500400Weight),
                    verticalSpace(16),
                    Text(
                      city,
                      style: TextStyles.font16Primary500400Weight,
                    ),
                  ],
                ),
                VDivider(39.h),

                // الحي
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحي',
                        style: TextStyles.font16Dark500400Weight),
                    verticalSpace(16),
                    SizedBox(
                      width: 100.w,
                      child: Text(
                        areas.isEmpty ? '' : areas.join(', '),
                        style: TextStyles.font16Primary500400Weight,
                        overflow: TextOverflow.ellipsis,
                      ),
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
