import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstateCategorySelectorBottomSheetView extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const RealEstateCategorySelectorBottomSheetView({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onSelectCategory,
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
              Text('التصنيف', style: TextStyles.font20Black500Weight),
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
              itemCount: categories.length,
              separatorBuilder: (context, index) => MyDivider(height: 4.w),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;
                return ListTile(
                  title: Row(
                    children: [
                      MySvg(
                          image: isSelected
                              ? 'tick-square-check'
                              : 'tick-square'),
                      horizontalSpace(8.w),
                      Text(cat),
                    ],
                  ),
                  onTap: () => onSelectCategory(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
