import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

class FilterRangeSliderSection extends StatefulWidget {
  const FilterRangeSliderSection({super.key});

  @override
  State<FilterRangeSliderSection> createState() =>
      _FilterRangeSliderSectionState();
}

class _FilterRangeSliderSectionState extends State<FilterRangeSliderSection> {
  int _lowerValue = 50;
  int _upperValue = 350;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'السعر',
          style: TextStyles.font20Black500Weight,
        ),
        verticalSpace(16),
        RangeSlider(
          values: RangeValues(_lowerValue.toDouble(), _upperValue.toDouble()),
          onChanged: (values) {
            setState(() {
              _lowerValue = values.start.round();
              _upperValue = values.end.round();
            });
          },
          labels: RangeLabels(
            _lowerValue.toString(),
            _upperValue.toString(),
          ),
          min: 0,
          max: 1000,
          activeColor: ColorsManager.primaryColor,
          inactiveColor: ColorsManager.sliderInactiveColor,
        ),
        verticalSpace(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '$_lowerValue K',
              style: TextStyles.font14Blue500Weight,
            ),
            Text(
              '$_upperValue K',
              style: TextStyles.font14Blue500Weight,
            ),
          ],
        ),
      ],
    );
  }
}
