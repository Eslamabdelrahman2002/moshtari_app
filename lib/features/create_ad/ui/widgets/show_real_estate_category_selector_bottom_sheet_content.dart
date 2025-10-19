import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstateCitySelectorBottomSheetView extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String> onSelectCity;

  const RealEstateCitySelectorBottomSheetView({
    super.key,
    required this.cities,
    this.selectedCity,
    required this.onSelectCity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const MySvg(image: 'arrow-right')),
              const Spacer(),
              Text('المدينة', style: TextStyles.font20Black500Weight),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          verticalSpace(24.h),
          Expanded(
            child: ListView.separated(
              itemCount: cities.length,
              separatorBuilder: (context, index) => MyDivider(height: 4.w),
              itemBuilder: (context, index) {
                final city = cities[index];
                final isSelected = city == selectedCity;
                return ListTile(
                  title: Row(
                    children: [
                      MySvg(
                          image: isSelected
                              ? 'tick-square-check'
                              : 'tick-square'),
                      horizontalSpace(8.w),
                      Text(city),
                    ],
                  ),
                  onTap: () => onSelectCity(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
