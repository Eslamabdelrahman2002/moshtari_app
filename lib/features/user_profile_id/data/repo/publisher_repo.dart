import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/features/user_profile/data/model/my_ads_model.dart';
import 'package:mushtary/features/user_profile/data/model/my_auctions_model.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/api/api_constants.dart';

class PublisherRepo {
  final ApiService _api;

  PublisherRepo(this._api);

  /// 🔹 إعلانات الناشر
  Future<List<MyAdsModel>> getPublisherAds(int userId, {int page = 1, int limit = 10}) async {
    try {
      final data = await _api.get(
        // السيرفر يقبل /car-ads/my-ads?user_id=xxx
        '${ApiConstants.carAds}/my-ads',
        queryParameters: {'user_id': userId, 'page': page, 'limit': limit},
      );

      final List list = (data['data'] as List?) ?? const [];
      return list.map((e) => MyAdsModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('فشل جلب إعلانات الناشر: $e');
    }
  }

  /// 🔹 مزادات الناشر
  Future<List<MyAuctionModel>> getPublisherAuctions(int userId, {int page = 1, int limit = 10}) async {
    try {
      final data = await _api.get(
        // السيرفر يقبل /car-auctions/my-auctions?user_id=xxx
        ApiConstants.myAuctions,
        queryParameters: {'user_id': userId, 'page': page, 'limit': limit},
      );

      final List list = (data['data'] as List?) ?? const [];
      return list.map((e) => MyAuctionModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('فشل جلب مزادات الناشر: $e');
    }
  }
}