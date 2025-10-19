import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class CategoryItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    this.isSelected = false,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorsManager.purple.withOpacity(0),
              ColorsManager.purple.withOpacity(0.08),
            ],
          )
              : null,
          border: isSelected
              ? Border(
            bottom: BorderSide(
              color: ColorsManager.primaryColor,
              width: 4.w,
            ),
          )
              : Border(
            bottom: BorderSide(
              color: ColorsManager.lightGrey,
              width: 2.w,
            ),
          ),
        ),
        child: Text(
          name,
          style: isSelected
              ? TextStyles.font14Blue500Weight
              : TextStyles.font14DarkGray400Weight,
        ),
      ),
    );
  }
}
