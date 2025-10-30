// file: notifications_repo.dart

import 'package:mushtary/core/api/api_service.dart' as api;
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/features/notifications/data/model/notification_model.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart'; // نحتاج لاستيراد CacheHelper

class NotificationsRepo {
  final api.ApiService _apiService;

  NotificationsRepo(this._apiService);

  // ✅ FIX: دالة مساعدة للحصول على معرف المستخدم غير الثابت
  int _getCurrentUserId() {
    // يجب استبدال 'userId' بالمفتاح الفعلي الذي تخزّن فيه معرف المستخدم بعد تسجيل الدخول
    return CacheHelper.getData(key: 'userId') as int? ?? 0;
  }

  Future<NotificationsResponse> getNotifications() async {
    final currentUserId = _getCurrentUserId();

    if (currentUserId == 0) {
      // ✅ يتم طرح هذا الاستثناء حالياً لعدم وجود userId في CacheHelper
      throw Exception("User ID not found. Please log in.");
    }

    try {
      // ✅ FIX: استخدام المعرّف الفعلي وتمرير endpoint كـ Positional Argument
      final response = await _apiService.get(
        ApiConstants.getNotifications(currentUserId),
        queryParameters: {'limit': 20, 'page': 1, 'IncludeRead': false},
        requireAuth: true,
      );

      // ✅ FIX: التأكد من تحويل response.data إلى Map<String, dynamic> قبل التحليل
      if (response is Map<String, dynamic>) {
        return NotificationsResponse.fromJson(response);
      } else {
        throw Exception("Unexpected API response format for notifications.");
      }

    } catch (e) {
      rethrow;
    }
  }

  /// تحديث حالة إشعار واحد
  Future<void> markNotificationAsRead(int notificationId) async {
    await _apiService.postNoData(
      ApiConstants.markNotificationAsRead(notificationId),
      requireAuth: true,
    );
  }

  /// تحديد جميع الإشعارات كمقروءة
  Future<void> markAllNotificationsAsRead() async {
    await _apiService.postNoData(
      ApiConstants.readAllNotifications,
      requireAuth: true,
    );
  }
}