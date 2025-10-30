// file: notification_item.dart (هذا هو الملف الذي تم تعديله ليصبح Widget)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/notifications/data/model/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../cubit/notifications_cubit.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification; // ✅ تم إضافة حقل البيانات الحقيقية
  final bool isJudgeNotification;
  final bool isReaded;

  const NotificationItem({
    super.key,
    required this.notification, // ✅ تم جعله مطلوباً
    this.isJudgeNotification = false,
    this.isReaded = true,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    // نستخدم notification.isRead مباشرة بدلاً من isReaded (لأنها الآن تأتي من الـ Model)
    final bool currentlyRead = notification.isRead;

    return GestureDetector(
      onTap: () {
        if (!currentlyRead) {
          // استدعاء Cubit لتحديث حالة القراءة عند الضغط
          BlocProvider.of<NotificationsCubit>(context)
              .setNotificationAsRead(notification.id);
        }
        // TODO: إضافة منطق التنقل للصفحة المحددة في notification.screen
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          // تغيير لون الخلفية للإشعارات غير المقروءة
          color: currentlyRead ? Colors.white : Colors.grey.shade50,
          border: isJudgeNotification
              ? Border.all(color: const Color(0xffFFE499), width: 1.w)
              : null,
          borderRadius: isJudgeNotification ? BorderRadius.circular(12.r) : null,
        ),
        child: Row(
          children: [
            // عرض النقطة الزرقاء للإشعارات غير المقروءة وغير القضائية
            if (!isJudgeNotification && !currentlyRead)
              CircleAvatar(
                backgroundColor: ColorsManager.primary400,
                radius: 4.r,
              ),
            // عرض أيقونة Judge للإشعارات القضائية
            if (isJudgeNotification) const MySvg(image: 'notification_judge'),

            horizontalSpace(8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                            notification.title, // ✅ استخدام العنوان الحقيقي
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.font14Black500Weight,
                          )),
                      horizontalSpace(8),
                      Text(
                        // ✅ استخدام وقت الإنشاء الحقيقي
                        timeago.format(
                          notification.createdAt.toLocal(), // .toLocal() لضمان عرض الوقت الصحيح للمستخدم
                          locale: 'ar',
                        ),
                        style: TextStyles.font10DarkGray400Weight,
                      ),
                    ],
                  ),
                  verticalSpace(4),
                  Text(
                    notification.body, // ✅ استخدام محتوى الإشعار الحقيقي
                    style: TextStyles.font12Dark500400Weight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}