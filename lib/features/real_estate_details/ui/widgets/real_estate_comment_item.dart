import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/fonts.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:special_text_between_marks/special_text_between_marks.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorsManager.darkGray400,
            shape: BoxShape.circle,
            border: Border.all(color: ColorsManager.grey100, strokeAlign: 1),
          ),
          child: const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/images/img.png'),
          ),
        ),
        horizontalSpace(4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 322.w,
              child: Row(
                children: [
                  Text('Abdullah Al Suhail',
                      style: TextStyles.font14Black500Weight),
                  horizontalSpace(8),
                  // const UserTag(),
                  const Spacer(),
                  MySvg(
                    image: 'more',
                    width: 24.w,
                    height: 24.h,
                  ),
                ],
              ),
            ),
            verticalSpace(4),
            Container(
              width: 322.w,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorsManager.dark50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(4.r),
                ),
              ),
              child: SpecialTextBetweenMarks(
                text:
                    '"@Mahmud" لنص يمكن أن يستبدل في نفس المساحة، لقد تم توليد هذا النص من مولد النص العربى، حيث يمكنك أن تولد مثل هذا النص أو العديد من النصوص الأخرى إضافة إلى زيادة عدد الحروف التى يولدها التطبيق.',
                openMark: '"',
                closeMark: '"',
                normalStyle: TextStyles.font14Black500Weight
                    .copyWith(fontFamily: appArabicFontFamily),
                specialStyle: TextStyles.font14secondary600yellow400Weight
                    .copyWith(fontFamily: appArabicFontFamily),
              ),
            ),
            SizedBox(
              width: 322.w,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MySvg(
                          image: 'solar_reply',
                          width: 24.w,
                          height: 24.h,
                        ),
                        horizontalSpace(4),
                        Text(
                          'الرد',
                          style: TextStyles.font12Blue400Weight,
                        ),
                      ],
                    ),
                    Text('منذ 3 ساعات',
                        style: TextStyles.font12DarkGray400Weight),
                  ],
                ),
              ),
            ),
            verticalSpace(12)
          ],
        ),
      ],
    );
  }
}
