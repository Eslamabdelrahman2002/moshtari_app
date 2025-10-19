// lib/features/home/data/repo/home_repo.dart
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';

class HomeRepo {
  final ApiService _apiService;
  HomeRepo(this._apiService);

  Future<HomeDataModel> getHomeData() async {
    try {
      final response = await _apiService.get(ApiConstants.home);
      // response = {"success":true,"message":"...","data":{...}}
      if (response is Map<String, dynamic> && response['data'] is Map<String, dynamic>) {
        return HomeDataModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw  AppException('Unexpected response shape');
    } catch (e) {
      throw AppException('Failed to load home data: $e');
    }
  }
}