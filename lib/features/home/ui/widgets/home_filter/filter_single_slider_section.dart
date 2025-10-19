import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

class FilterSingleSliderSection extends StatefulWidget {
  const FilterSingleSliderSection({super.key});

  @override
  State<FilterSingleSliderSection> createState() =>
      _FilterSingleSliderSectionState();
}

class _FilterSingleSliderSectionState extends State<FilterSingleSliderSection> {
  int spaceSliderValue = 400;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'محيط المسافة',
          style: TextStyles.font20Black500Weight,
        ),
        verticalSpace(16),
        Slider(
          value: spaceSliderValue.toDouble(),
          min: 0,
          max: 1000,
          onChanged: (value) {
            setState(() {
              spaceSliderValue = value.round();
            });
          },
          activeColor: ColorsManager.primaryColor,
          inactiveColor: ColorsManager.sliderInactiveColor,
          label: '$spaceSliderValue كم',
        ),
        verticalSpace(8),
        Center(
            child: Text(
          '$spaceSliderValue كم',
          style: TextStyles.font14Blue500Weight,
        )),
      ],
    );
  }
}
