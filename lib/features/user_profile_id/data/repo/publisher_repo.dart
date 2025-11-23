// lib/features/user_profile_id/data/repo/publisher_repo.dart

import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/features/user_profile_id/data/model/my_ads_model.dart';
import 'package:mushtary/features/user_profile_id/data/model/my_auctions_model.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/api/api_constants.dart';

class PublisherRepo {
  final ApiService _api;

  PublisherRepo(this._api);

  bool _isEmptyNotFound(AppException e) {
    final msg = e.message.toString();
    final code = (e as dynamic).statusCode as int?; // يدعم لو AppException فيها statusCode
    // اعتبر 404/204 أو رسائل "لا يوجد ..." كحالة Empty
    if (code == 404 || code == 204) return true;
    if (msg.contains('لا يوجد')) return true;
    if (msg.toLowerCase().contains('no ads') ||
        msg.toLowerCase().contains('not found') ||
        msg.toLowerCase().contains('no auctions')) return true;
    return false;
  }

  List _extractList(dynamic data) {
    // غالباً السيرفر بيرجع { data: [...] }
    if (data is Map && data['data'] is List) return data['data'] as List;
    // fallback في حال رجع هيكل مختلف
    if (data is List) return data;
    return const [];
  }

  /// إعلانات الناشر (المسار: /car-ads/my-ads/{userId})
  Future<List<MyAdsModel>> getPublisherAds(int userId, {int page = 1, int limit = 10}) async {
    try {
      final data = await _api.get(
        ApiConstants.getPublisherAds(userId),
        requireAuth: true,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = _extractList(data);
      return list.map((e) => MyAdsModel.fromJson(e)).toList();
    } on AppException catch (e) {
      // لو 404 أو الرسالة بتقول "لا يوجد" رجّع قائمة فاضية
      if (_isEmptyNotFound(e)) return <MyAdsModel>[];
      throw AppException('فشل جلب إعلانات الناشر: ${e.message}');
    } catch (e) {
      throw AppException('فشل جلب إعلانات الناشر: $e');
    }
  }

  /// مزادات الناشر (المسار: /car-auctions/my-auctions/{userId})
  Future<List<MyAuctionModel>> getPublisherAuctions(int userId, {int page = 1, int limit = 10}) async {
    try {
      final data = await _api.get(
        ApiConstants.getPublisherAuctions(userId),
        requireAuth: true, // لو الendpoint يتطلب توثيق، خليه true
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = _extractList(data);
      return list.map((e) => MyAuctionModel.fromJson(e)).toList();
    } on AppException catch (e) {
      if (_isEmptyNotFound(e)) return <MyAuctionModel>[];
      throw AppException('فشل جلب مزادات الناشر: ${e.message}');
    } catch (e) {
      throw AppException('فشل جلب مزادات الناشر: $e');
    }
  }
}