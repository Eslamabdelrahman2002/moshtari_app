import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/notifications/ui/widgets/notification_item.dart';
import 'package:mushtary/features/notifications/ui/widgets/notifications_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const NotificationAppBar(),
            verticalSpace(24),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemBuilder: (context, index) {
                  return NotificationItem(
                    isJudgeNotification: index % 2 == 0,
                    isReaded: index % 3 == 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
