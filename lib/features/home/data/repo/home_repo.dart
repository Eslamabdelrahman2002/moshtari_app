import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/data/models/ads_filter.dart';

class HomeRepo {
  final ApiService _apiService;
  HomeRepo(this._apiService);

  Future<HomeDataModel> getHomeData() async {
    try {
      final response = await _apiService.get(ApiConstants.home);
      if (response is Map<String, dynamic> && response['data'] is Map<String, dynamic>) {
        return HomeDataModel.fromJson(Map<String, dynamic>.from(response['data']));
      }
      throw AppException('Unexpected response shape');
    } catch (e) {
      throw AppException('Failed to load home data: $e');
    }
  }

  // بحث نصي -> /users/search?query=
  Future<List<HomeAdModel>> searchAds(AdsFilter filter) async {
    try {
      final response = await _apiService.get(
        ApiConstants.usersSearch,
        queryParameters: filter.toSearchQuery(),
      );
      if (response is! Map || response['data'] is! Map) {
        throw AppException('Unexpected response shape');
      }
      final data = Map<String, dynamic>.from(response['data']);
      final homeLike = HomeDataModel.fromJson(data);
      return <HomeAdModel>[
        ...homeLike.carAds,
        ...homeLike.realEstateAds,
        ...homeLike.carPartsAds,
        ...homeLike.otherAds,
        ...homeLike.auctions.map(HomeAdModel.fromAuction),
      ];
    } catch (e) {
      throw AppException('Search failed: $e');
    }
  }

  // فلترة -> /users/home
  Future<List<HomeAdModel>> filterAds(AdsFilter filter) async {
    try {
      final response = await _apiService.get(
        ApiConstants.home,
        queryParameters: filter.toHomeFilterQuery(),
      );
      if (response is! Map || response['data'] is! Map) {
        throw AppException('Unexpected response shape');
      }
      final data = Map<String, dynamic>.from(response['data']);
      final homeLike = HomeDataModel.fromJson(data);
      return <HomeAdModel>[
        ...homeLike.carAds,
        ...homeLike.realEstateAds,
        ...homeLike.carPartsAds,
        ...homeLike.otherAds,
        ...homeLike.auctions.map(HomeAdModel.fromAuction),
      ];
    } catch (e) {
      throw AppException('Filter failed: $e');
    }
  }
}