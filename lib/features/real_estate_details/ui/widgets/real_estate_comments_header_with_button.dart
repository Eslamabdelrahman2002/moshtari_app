import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CommentsHeaderWithButton extends StatelessWidget {
  const CommentsHeaderWithButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('التعليقات', style: TextStyles.font16Dark300Grey400Weight),
          horizontalSpace(2),
          Text(
            '(15)',
            style: TextStyles.font16Black500Weight,
          ),
          const Spacer(),
          MaterialButton(
            onPressed: () {},
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            height: 24.h,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: const BorderSide(
                    strokeAlign: 1, color: ColorsManager.primaryColor)),
            color: ColorsManager.white,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MySvg(
                  image: 'add_lines',
                  height: 16.h,
                  width: 16.w,
                ),
                horizontalSpace(4),
                Text(
                  'متابعه الاعلان',
                  style: TextStyles.font12Blue400Weight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
