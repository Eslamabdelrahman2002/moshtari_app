import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';

class ElectronicsSegmentedInfoPanel extends StatelessWidget {
  const ElectronicsSegmentedInfoPanel({
    super.key,
    this.category = '',
    this.city = '',
    this.areas = const [],
  });

  final String category;
  final String city;
  final List<String> areas;

  @override
  Widget build(BuildContext context) {
    final joinedAreas = areas.join(', ');

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoColumn(title: 'التصنيف', value: category),
            VDivider(39.h),
            _InfoColumn(title: 'المدينه', value: city),
            VDivider(39.h),
            _InfoColumn(title: 'الحي', value: joinedAreas),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyles.font16Dark500400Weight),
        verticalSpace(16),
        SizedBox(
          width: 100.w,
          child: Text(
            value,
            style: TextStyles.font16Primary500400Weight,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
