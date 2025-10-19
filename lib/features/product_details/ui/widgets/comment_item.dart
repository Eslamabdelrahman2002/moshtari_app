import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:special_text_between_marks/special_text_between_marks.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {
  final String userName;
  final String comment;
  final DateTime? createdAt;

  const CommentItem({
    super.key,
    required this.userName,
    required this.comment,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // timeago بالعربي
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    final timeString = createdAt == null
        ? ''
        : timeago.format(createdAt!.toLocal(), locale: 'ar');

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
                  Text(userName.isEmpty ? 'مستخدم' : userName,
                      style: TextStyles.font14Black500Weight),
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
                text: comment.isEmpty
                    ? '...'
                    : comment,
                openMark: '"',
                closeMark: '"',
                normalStyle: TextStyles.font14Black500Weight,
                specialStyle: TextStyles.font14secondary600yellow400Weight,
              ),
            ),
            SizedBox(
              width: 322.w,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    timeString,
                    style: TextStyles.font12DarkGray400Weight,
                  ),
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