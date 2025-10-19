import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';

class PrimaryCheckBox extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  const PrimaryCheckBox({
    super.key,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            border: isEnabled
                ? null
                : Border.all(color: ColorsManager.lightGrey, width: 1.5),
            color: isEnabled ? ColorsManager.primaryColor : ColorsManager.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isEnabled
              ? const Icon(
                  Icons.check,
                  color: ColorsManager.white,
                  size: 20,
                )
              : null),
    );
  }
}
