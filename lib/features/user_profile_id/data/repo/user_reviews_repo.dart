import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/user_profile_id/data/model/review_model.dart';

class UserReviewsRepo {
  final ApiService _apiService;

  UserReviewsRepo(this._apiService);

  Future<Map<String, dynamic>> getUserReviews(int userId) async {
    try {
      // 🔹 1. جلب بيانات المستخدم (التي تحتوي على التقييمات)
      final userResponse = await _apiService.get(
        ApiConstants.userProfile,
        queryParameters: {'user_id': userId},
        requireAuth: true,
      );

      if (userResponse is! Map<String, dynamic> ||
          !(userResponse['success'] ?? false)) {
        throw AppException('فشل في جلب بيانات الملف الشخصي.');
      }

      // 🔹 2. استخراج البيانات من المفتاح الصحيح "user"
      final rawUser = userResponse['user'] ?? userResponse['data'];
      final Map<String, dynamic> userData =
      (rawUser is Map<String, dynamic>) ? rawUser : <String, dynamic>{};

      // 🔹 3. استخراج قائمة التقييمات من داخل userData['reviews']
      final List<dynamic> reviewsRaw =
          (userData['reviews'] as List<dynamic>?) ?? [];

      final reviews = reviewsRaw.map((item) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      // 🔹 4. إرجاع البيانات للـ Cubit
      return {
        'user': userData,
        'reviews': reviews,
      };
    } catch (e, s) {
      // ignore: avoid_print
      print('🔴 [Repo Error] $e');
      // ignore: avoid_print
      print('🔴 STACK: $s');
      rethrow;
    }
  }
}