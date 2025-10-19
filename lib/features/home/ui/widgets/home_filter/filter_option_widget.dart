import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class FilterOptionWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool isSelected;
  const FilterOptionWidget({
    super.key,
    required this.onPressed,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: onPressed,
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 18.h,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected ? ColorsManager.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: isSelected
                  ? null
                  : Border.all(
                      color: ColorsManager.dark200,
                      width: 1.w,
                    ),
            ),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isSelected
                  ? TextStyles.font14White500Weight
                  : TextStyles.font14Black500Weight,
            )),
      ),
    );
  }
}
