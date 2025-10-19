import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_chip.dart';

class RealEstateToggleBar extends StatelessWidget {
  final Function onAdSelect;
  final Function onApplicationsSelect;
  final bool isApplicationsSelected;
  const RealEstateToggleBar({
    super.key,
    required this.onAdSelect,
    required this.onApplicationsSelect,
    required this.isApplicationsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: RealEstateChip(
              title: 'إعلانات',
              onSelect: onAdSelect,
              isSelected: !isApplicationsSelected,
            ),
          ),
          Expanded(
            child: RealEstateChip(
              title: 'طلبات',
              onSelect: onApplicationsSelect,
              isSelected: isApplicationsSelected,
            ),
          ),
        ],
      ),
    );
  }
}
