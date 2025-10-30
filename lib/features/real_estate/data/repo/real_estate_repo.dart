import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_filter_params.dart';
import 'package:mushtary/features/real_estate_details/date/model/real_estate_details_model.dart';

class RealEstateRepo {
  final ApiService _apiService;

  RealEstateRepo(this._apiService);

  /// Get All Real Estate Ads
  Future<List<RealEstateListModel>> getRealEstateAds() async {
    try {
      final response = await _apiService.get(ApiConstants.realEstateAds);
      final List<dynamic> data = response['data'];
      return data.map((json) => RealEstateListModel.fromJson(json)).toList();
    } catch (e) {
      throw AppException("Failed to load ads: $e");
    }
  }


  /// Get Single Ad Details by ID
  Future<RealEstateDetailsModel> getRealEstateAdById(int id) async {
    try {
      final response =
      await _apiService.get("${ApiConstants.realEstateAds}/$id");
      return RealEstateDetailsModel.fromJson(response['data']);
    } catch (e) {
      throw AppException("Failed to load ad details: $e");
    }
  }
  Future<List<RealEstateListModel>> getFilteredRealEstateAds(
      RealEstateFilterParams params) async {
    try {
      final response = await _apiService.get(
        ApiConstants.realEstateAds,
        queryParameters: params.toJson(),
      );
      final List<dynamic> data = response['data'];
      return data.map((json) => RealEstateListModel.fromJson(json)).toList();
    } catch (e) {
      throw AppException("Failed to load filtered ads: $e");
    }
  }

  /// Delete Ad
  Future<void> deleteRealEstateAd(int id) async {
    try {
      await _apiService.deleteWithBody("${ApiConstants.realEstateAds}/$id");
    } catch (e) {
      throw AppException("Failed to delete ad: $e");
    }
  }
}
