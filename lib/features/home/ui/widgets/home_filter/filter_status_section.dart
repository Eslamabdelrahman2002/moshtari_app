import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_option_widget.dart';

class FilterStatusSection extends StatelessWidget {
  const FilterStatusSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'الحالة',
          style: TextStyles.font20Black500Weight,
        ),
        verticalSpace(16),
        Row(
          children: [
            FilterOptionWidget(
              onPressed: () {},
              title: 'جديد',
              isSelected: false,
            ),
            horizontalSpace(16),
            FilterOptionWidget(
              onPressed: () {},
              title: 'مستخدم',
              isSelected: false,
            ),
            horizontalSpace(16),
            FilterOptionWidget(
              onPressed: () {},
              title: 'الكل',
              isSelected: true,
            ),
          ],
        ),
      ],
    );
  }
}
