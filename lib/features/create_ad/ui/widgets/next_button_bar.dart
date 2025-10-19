import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';

class NextButtonBar extends StatelessWidget {
  final String? title;
  final void Function()? onPressed;
  const NextButtonBar({
    super.key,
    this.onPressed,
    this.title = 'التالي',
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      label: title,
      labelStyle: TextStyles.font16White500Weight,
      textColor:
          onPressed != null ? ColorsManager.white : ColorsManager.primaryColor,
      height: 52.h,
      backgroundColor:
          onPressed != null ? ColorsManager.primary500 : ColorsManager.primaryColor,
      onPressed: onPressed,
      radius: 12.r,
    );
  }
}
