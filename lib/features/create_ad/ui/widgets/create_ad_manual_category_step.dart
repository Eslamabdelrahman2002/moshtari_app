import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../../../core/enums/create_ad_category.dart';

class CreateAdManualCategoryStep extends StatelessWidget {
  final ValueChanged<CreateAdCategory> onTap;
  const CreateAdManualCategoryStep({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        children: [
          _catTile(
            icon: "car",
            title: 'سيارات',
            onPressed: () => onTap(CreateAdCategory.cars),
          ),
          SizedBox(height: 10.h),
          _catTile(
            icon: "building-3-duotone",
            title: 'عقارات',
            onPressed: () => onTap(CreateAdCategory.realEstate),
          ),
          SizedBox(height: 10.h),
          _catTile(
            icon: "electricity-duotone",
            title: 'قطع غيار السيارات',
            onPressed: () => onTap(CreateAdCategory.devices), // كما في الراوتر
          ),
          SizedBox(height: 10.h),
          _catTile(
            icon: "other",
            title: 'أخرى',
            onPressed: () => onTap(CreateAdCategory.other),
          ),
        ],
      ),
    );
  }

  Widget _catTile({
    required String icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          height: 65.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: ColorsManager.dark200, width: 1),
          ),
          child: Row(
            children: [
              MySvg(image: icon),
              SizedBox(width: 15.w),
              Expanded(child: Text(title, style: TextStyles.font16Black500Weight)),
              const Icon(Icons.arrow_forward_ios_outlined, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}