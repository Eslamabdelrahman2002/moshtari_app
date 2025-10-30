// file: lib/features/notifications/logic/cubit/notifications_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/notifications/data/model/notification_model.dart';
import 'package:mushtary/features/notifications/data/repo/notifications_repo.dart';

// --- State ---
abstract class NotificationsState {}
class NotificationsInitial extends NotificationsState {}
class NotificationsLoading extends NotificationsState {}
class NotificationsSuccess extends NotificationsState {
  final List<NotificationModel> notifications;
  NotificationsSuccess(this.notifications);
}
class NotificationsError extends NotificationsState {
  final String error;
  NotificationsError(this.error);
}
// -----------------

// --- Cubit ---
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _notificationsRepo;

  NotificationsCubit(this._notificationsRepo) : super(NotificationsInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationsLoading());
    try {
      final response = await _notificationsRepo.getNotifications();
      emit(NotificationsSuccess(response.data));
    } catch (e) {
      // يمكن استخدام رسائل خطأ أكثر وداً للمستخدم هنا
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> setNotificationAsRead(int notificationId) async {
    // 1. تحديث تفاؤلي لواجهة المستخدم (Optimistic UI update)
    if (state is NotificationsSuccess) {
      final currentNotifications = (state as NotificationsSuccess).notifications;
      final updatedList = currentNotifications.map((notif) {
        return notif.id == notificationId
            ? notif.copyWith(isRead: true)
            : notif;
      }).toList();
      emit(NotificationsSuccess(updatedList));
    }

    try {
      // 2. طلب API لتأكيد القراءة
      await _notificationsRepo.markNotificationAsRead(notificationId);
    } catch (e) {
      // في حالة فشل طلب API، يمكن إضافة منطق للتراجع عن التحديث التفاؤلي
      print('Failed to mark notification $notificationId as read: $e');
    }
  }
}