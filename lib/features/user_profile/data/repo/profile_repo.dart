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
    // استخدم FormData لو فيه صورة
    final formData = FormData.fromMap({
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      if (profilePicture != null)
        'profile_picture': await MultipartFile.fromFile(profilePicture.path),
    });

    await apiService.put(
      ApiConstants.userProfile,
      data: formData,
    );
  }

  Future<List<MyAdsModel>> getMyAds({int page = 1, int limit = 10}) async {
    final data = await apiService.get(
      '${ApiConstants.baseUrl}car-ads/my-ads',
      queryParameters: {'page': page, 'limit': limit},
    );
    final List<dynamic> list = data['data'] ?? [];
    return list.map((e) => MyAdsModel.fromJson(e)).toList();
  }

  Future<List<MyAuctionModel>> getMyAuctions({int page = 1, int limit = 10}) async {
    final data = await apiService.get(
      '${ApiConstants.baseUrl}car-auctions/my-auctions',
      queryParameters: {'page': page, 'limit': limit},
    );
    final List<dynamic> list = data['data'] ?? [];
    return list.map((e) => MyAuctionModel.fromJson(e)).toList();
  }
}
