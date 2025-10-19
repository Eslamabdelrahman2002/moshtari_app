import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_option_widget.dart';

class FilterOtherSection extends StatelessWidget {
  const FilterOtherSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'أخري',
          style: TextStyles.font20Black500Weight,
        ),
        verticalSpace(16),
        Row(
          children: [
            FilterOptionWidget(
              onPressed: () {},
              title: 'صور فقط',
              isSelected: false,
            ),
            horizontalSpace(16),
            FilterOptionWidget(
              onPressed: () {},
              title: 'القريب',
              isSelected: false,
            ),
            horizontalSpace(16),
            FilterOptionWidget(
              onPressed: () {},
              title: 'الاحدث',
              isSelected: false,
            ),
          ],
        ),
      ],
    );
  }
}
