import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorsManager.white,
      surfaceTintColor: ColorsManager.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 306.h,
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
          child: Column(
            children: [
              Text('مشاركة الرابط بواسطة',
                  style: TextStyles.font20Black500Weight),
              verticalSpace(32),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: MySvg(
                        image: 'link',
                        width: 40.w,
                        height: 40.h,
                      )),
                  horizontalSpace(24),
                  GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: MySvg(
                        image: 'logos_facebook',
                        width: 40.w,
                        height: 40.h,
                      )),
                  horizontalSpace(24),
                  GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: MySvg(
                        image: 'logos_telegram',
                        width: 40.w,
                        height: 40.h,
                      )),
                  horizontalSpace(24),
                  GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: MySvg(
                        image: 'logos_whatsapp-icon',
                        width: 40.w,
                        height: 40.h,
                      )),
                ],
              ),
              verticalSpace(32),
              MyButton(
                label: 'سوق للأعلان',
                image: 'loudspeaker',
                minWidth: 326.w,
                onPressed: () {
                  context.pop();
                },
                backgroundColor: ColorsManager.primary50,
                radius: 16,
                height: 40.h,
                labelStyle: TextStyles.font12Primary400400Weight,
              ),
              verticalSpace(32),
              MyButton(
                label: 'حسنا',
                minWidth: 326.w,
                onPressed: () {
                  context.pop();
                },
                backgroundColor: ColorsManager.primaryColor,
                radius: 12,
                height: 52.h,
                labelStyle: TextStyles.font16White500Weight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
