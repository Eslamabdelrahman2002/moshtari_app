import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/features/create_ad/ui/widgets/create_ad_category_item.dart';
import '../../../../core/enums/create_ad_category.dart';
import '../../../../core/router/routes.dart';

class CreateAdCategoryList extends StatelessWidget {
  final ValueChanged<CreateAdCategory> onTap;
  const CreateAdCategoryList({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أختر التصنيف', style: TextStyles.font14Black500Weight),
          SingleChildScrollView(
            child: Column(
              children: [
                CreateAdCategoryItem(
                  icon: 'car-duotone',
                  title: 'سيارات',
                  onTap: () => onTap(CreateAdCategory.cars),
                ),
                MyDivider(height: 16.h),
                CreateAdCategoryItem(
                  icon: 'building-duotone',
                  title: 'عقارات',
                  onTap: () => onTap(CreateAdCategory.realEstate),
                ),
                MyDivider(height: 16.h),
                CreateAdCategoryItem(
                  icon: 'electricity-duotone',
                  title: 'قطع غيار السيارات',
                  onTap: () => Navigator.pushNamed(context, Routes.createCarPartAdScreen),
                ),
                MyDivider(height: 16.h),
                CreateAdCategoryItem(
                  icon: 'pet-duotone',
                  title: 'حيوانات و طيور',
                  onTap: () => onTap(CreateAdCategory.other),
                ),
                MyDivider(height: 16.h),
                CreateAdCategoryItem(
                  icon: 'electricity-duotone',
                  title: 'قطع غيار السيارات', // تصحيح إملائي
                  onTap: () => onTap(CreateAdCategory.other),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}