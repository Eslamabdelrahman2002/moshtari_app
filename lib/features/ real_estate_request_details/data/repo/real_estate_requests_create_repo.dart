// lib/features/create_ad/data/repo/real_estate_requests_create_repo.dart

import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

class RealEstateRequestsCreateRepo {
  final ApiService _apiService;

  RealEstateRequestsCreateRepo(this._apiService);

  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> data) async {
    // 💡 المسار المخصص لإنشاء الطلبات
    return await _apiService.post(
      ApiConstants.realEstateRequestsCreate,
      data,
      requireAuth: true,
    );
  }
}