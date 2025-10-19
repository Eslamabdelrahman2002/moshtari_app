import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class HomeFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String image;
  const HomeFloatingButton({
    super.key,
    required this.onPressed,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: ColorsManager.secondary500.withOpacity(0.65),
              shape: BoxShape.circle,
            ),
            child: MySvg(image: image)),
      ),
    );
  }
}
