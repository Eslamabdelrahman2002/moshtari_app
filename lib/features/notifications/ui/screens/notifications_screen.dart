// file: notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/notifications/ui/widgets/notification_item.dart';
import 'package:mushtary/features/notifications/ui/widgets/notifications_app_bar.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_empty_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  // ❌ تم حذف initState() لمنع مشاكل إنشاء مثيل Cubit مرتين

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const NotificationAppBar(),
            verticalSpace(24),
            Expanded(
              child: BlocProvider(
                // ✅ FIX: إنشاء Cubit وتفعيل عملية جلب البيانات فوراً
                create: (context) {
                  final cubit = getIt<NotificationsCubit>();
                  cubit.fetchNotifications();
                  return cubit;
                },
                child: BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    if (state is NotificationsLoading) {
                      return const Center(child: CircularProgressIndicator.adaptive());
                    }
                    // ✅ يتم عرض هذا الخطأ الآن حتى يتم حفظ userId في CacheHelper
                    else if (state is NotificationsError) {
                      return Center(child: Text('Error: ${state.error}'));
                    }
                    else if (state is NotificationsSuccess) {
                      if (state.notifications.isEmpty) {
                        return const NotificationsEmptyWidget();
                      }

                      return ListView.builder(
                        itemCount: state.notifications.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemBuilder: (context, index) {
                          final notification = state.notifications[index];

                          return NotificationItem(
                            notification: notification,
                            isJudgeNotification: notification.type == 'judge',
                            isReaded: notification.isRead,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}