import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import 'package:timeago/timeago.dart' as timeago;

class NotificationItem extends StatelessWidget {
  final bool isJudgeNotification;
  final bool isReaded;
  const NotificationItem({
    super.key,
    this.isJudgeNotification = false,
    this.isReaded = true,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isJudgeNotification
            ? Border.all(color: const Color(0xffFFE499), width: 1.w)
            : null,
        borderRadius: isJudgeNotification ? BorderRadius.circular(12.r) : null,
      ),
      child: Row(
        children: [
          if (isJudgeNotification) const MySvg(image: 'notification_judge'),
          if (!isJudgeNotification && !isReaded)
            CircleAvatar(
              backgroundColor: ColorsManager.primary400,
              radius: 4.r,
            ),
          horizontalSpace(8),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      'العميل سعيد للغاية سيتم',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font14Black500Weight,
                    )),
                    horizontalSpace(8),
                    Text(
                      timeago.format(
                        DateTime.now(),
                        locale: 'ar',
                      ),
                      style: TextStyles.font10DarkGray400Weight,
                    ),
                  ],
                ),
                verticalSpace(4),
                Text(
                  'العميل سعيد للغاية سيتم اتباعهاسيتم مضايقة جرة بولفينار ومطاردتها. كاخ  كاخا مضايقة مضايقة',
                  style: TextStyles.font12Dark500400Weight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
