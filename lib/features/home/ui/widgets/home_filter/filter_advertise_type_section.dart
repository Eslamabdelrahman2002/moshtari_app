import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_option_widget.dart';

class FilterAdvertiseTypeSection extends StatelessWidget {
  const FilterAdvertiseTypeSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'نوع الاعلان',
          style: TextStyles.font20Black500Weight,
        ),
        verticalSpace(16),
        Row(
          children: [
            FilterOptionWidget(
              onPressed: () {},
              title: 'مزاد',
              isSelected: false,
            ),
            horizontalSpace(16),
            FilterOptionWidget(
              onPressed: () {},
              title: 'مساومة',
              isSelected: false,
            ),
            horizontalSpace(16),
            FilterOptionWidget(
              onPressed: () {},
              title: 'سعر محدد',
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
