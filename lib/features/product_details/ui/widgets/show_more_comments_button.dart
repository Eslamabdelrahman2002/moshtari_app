import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ShowMoreCommentsButton extends StatelessWidget {
  final Function()? onTap;
  const ShowMoreCommentsButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                'عرض المزيد من التعليقات',
                style: TextStyles.font14Black500Weight,
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: MySvg(image: 'arrow-down', width: 16.w, height: 16.h),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
