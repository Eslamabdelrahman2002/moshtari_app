import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h, top: 12.w),
      child: Row(
        children: [
          MyButton(
            backgroundColor: Colors.white,
            label: 'أضف سومتك',
            labelStyle: TextStyles.font16Primary500500Weight,
            borderColor: ColorsManager.primaryColor,
            radius: 12.r,
            stroke: 1,
            onPressed: () {},
            minWidth: 178.w,
            height: 44.w,
            image: 'add_lines',
            iconWidth: 20.w,
            iconHeight: 20.w,
            gap: 6.w,
          ),
          const Spacer(),
          MyButton(
            minWidth: 44.w,
            height: 44.w,
            backgroundColor: ColorsManager.primary50,
            imageIcon: 'message',
            iconWidth: 20.w,
            iconHeight: 20.w,
            onPressed: () {},
            radius: 12.r,
          ),
          horizontalSpace(8),
          MyButton(
            minWidth: 44.w,
            height: 44.w,
            backgroundColor: ColorsManager.primary50,
            imageIcon: 'call-calling',
            iconWidth: 20.w,
            iconHeight: 20.w,
            onPressed: () {},
            radius: 12.r,
          ),
          horizontalSpace(8),
          MyButton(
            minWidth: 44.w,
            height: 44.w,
            backgroundColor: ColorsManager.success100,
            image: 'logos_whatsapp',
            iconWidth: 20.w,
            iconHeight: 20.w,
            onPressed: () {},
            radius: 12.r,
          ),
        ],
      ),
    );
  }
}
