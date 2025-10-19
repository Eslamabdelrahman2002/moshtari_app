import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class SecondaryTextFormFieldHasValue extends StatelessWidget {
  final String title;
  final Function() onTap;
  const SecondaryTextFormFieldHasValue({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.w,
      width: 358.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 250.w,
            child: Text(
              title,
              style: TextStyles.font16Primary500500Weight,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          InkWell(onTap: onTap, child: const MySvg(image: 'close-square'))
        ],
      ),
    );
  }
}
