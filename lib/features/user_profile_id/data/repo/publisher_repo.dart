// lib/features/user_profile_id/data/repo/publisher_repo.dart

import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/features/user_profile_id/data/model/my_ads_model.dart';
import 'package:mushtary/features/user_profile_id/data/model/my_auctions_model.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/api/api_constants.dart';

class PublisherRepo {
  final ApiService _api;

  PublisherRepo(this._api);

  /// 🔹 إعلانات الناشر (المسار: /car-ads/my-ads/{userId})
  Future<List<MyAdsModel>> getPublisherAds(int userId, {int page = 1, int limit = 10}) async {
    try {
      final data = await _api.get(
        ApiConstants.getPublisherAds(userId), // ✅ استخدام المسار الجديد بالـ ID
        requireAuth: true,
        queryParameters: {'page': page, 'limit': limit}, // إرسال pagination كـ query
      );

      final List list = (data['data'] as List?) ?? const [];
      return list.map((e) => MyAdsModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('فشل جلب إعلانات الناشر: $e');
    }
  }

  /// 🔹 مزادات الناشر (المسار: /car-auctions/my-auctions/{userId})
  Future<List<MyAuctionModel>> getPublisherAuctions(int userId, {int page = 1, int limit = 10}) async {
    try {
      final data = await _api.get(
        ApiConstants.getPublisherAuctions(userId), // ✅ استخدام المسار الجديد بالـ ID
        queryParameters: {'page': page, 'limit': limit}, // إرسال pagination كـ query
      );

      final List list = (data['data'] as List?) ?? const [];
      return list.map((e) => MyAuctionModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('فشل جلب مزادات الناشر: $e');
    }
  }
}