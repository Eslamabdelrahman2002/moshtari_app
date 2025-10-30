import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/user_profile_model.dart';
import '../model/my_ads_model.dart';
import '../model/my_auctions_model.dart';

class ProfileRepo {
  final ApiService apiService;
  ProfileRepo(this.apiService);

  Future<UserProfileModel> getUserProfile() async {
    final data = await apiService.get(ApiConstants.userProfile);
    return UserProfileModel.fromJson(data['data']);
  }

  Future<void> updateUserProfile({
    required String username,
    required String email,
    required String phoneNumber,
    File? profilePicture,
  }) async {
    final formData = FormData.fromMap({
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      if (profilePicture != null)
        'profile_picture': await MultipartFile.fromFile(profilePicture.path),
    });
    await apiService.put(ApiConstants.userProfile, data: formData);
  }

  Future<List<MyAdsModel>> getMyAds({int page = 1, int limit = 10}) async {
    final data = await apiService.get(
      'car-ads/my-ads',
      queryParameters: {'page': page, 'limit': limit},
    );
    final List list = (data['data'] as List?) ?? const [];
    return list.map((e) => MyAdsModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MyAuctionModel>> getMyAuctions({int page = 1, int limit = 10}) async {
    final data = await apiService.get(
      'car-auctions/my-auctions',
      queryParameters: {'page': page, 'limit': limit},
    );
    final List list = (data['data'] as List?) ?? const [];
    return list.map((e) => MyAuctionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deleteAccount() async {
    await apiService.deleteWithBody(ApiConstants.deleteAccount);
  }

  // ✅ Methods جديدة لجلب إعلانات ومزادات مستخدم آخر بناءً على userId
  Future<List<MyAdsModel>> getUserAds(int userId, {int page = 1, int limit = 10}) async {
    // ✅ استخدام endpoint لمستخدم آخر (افتراضي: 'car-ads/user/{userId}')
    // يمكن تعديل المسار حسب الـ API الحقيقي
    final data = await apiService.get(
      '${ApiConstants.carAds}/user/$userId', // أو 'car-ads/user/{userId}'
      queryParameters: {'page': page, 'limit': limit},
    );
    final List list = (data['data'] as List?) ?? const [];
    return list.map((e) => MyAdsModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MyAuctionModel>> getUserAuctions(int userId, {int page = 1, int limit = 10}) async {
    // ✅ استخدام endpoint لمستخدم آخر (افتراضي: 'car-auctions/user/{userId}')
    // يمكن تعديل المسار حسب الـ API الحقيقي
    final data = await apiService.get(
      'car-auctions/user/$userId', // أو استخدم ApiConstants إذا كان موجودًا
      queryParameters: {'page': page, 'limit': limit},
    );
    final List list = (data['data'] as List?) ?? const [];
    return list.map((e) => MyAuctionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // يحدد مسار الخدمة حسب نوع الإعلان
  String _segmentForCategory(int? categoryId) {
    switch (categoryId) {
      case 1: // سيارات
      case 5: // سيارات (قيم قديمة)
        return ApiConstants.carAds; // 'car-ads'
      case 2: // قطع غيار
        return ApiConstants.carPartAds; // 'car-part-ads'
      case 3: // عقارات
        return ApiConstants.realEstateAds; // 'real-estate-ads'
      case 4: // أخرى
        return ApiConstants.otherAds; // 'other-ads'
      default:
        return ApiConstants.carAds;
    }
  }

  // حذف إعلان من "إعلاناتي" حسب النوع
  Future<void> deleteMyAdByCategory({
    required int adId,
    required int? categoryId,
    required String phoneNumber,
  }) async {
    final segment = _segmentForCategory(categoryId);
    await apiService.deleteWithBody(
      '$segment/my-ads/$adId',
      data: {'phone_number': phoneNumber},
    );
  }
}