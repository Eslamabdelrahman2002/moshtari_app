import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_text_form_field.dart';

class CommentTextField extends StatelessWidget {
  const CommentTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      width: 358.w,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.dark50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 302.w,
            height: 32.h,
            child: const PrimaryTextFormField(
              validationError: '',
              hint: 'اكتب تعليقك هنا ...........',
              fillColor: ColorsManager.white,
            ),
          ),
          horizontalSpace(8),
          const MySvg(image: 'send-2'),
        ],
      ),
    );
  }
}
