// file: features/real_estate_requests/data/repo/real_estate_requests_repo.dart

import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import '../model/real_estate_request_details_model.dart';

class RealEstateRequestsRepo {
  final ApiService _api;
  RealEstateRequestsRepo(this._api);

  Future<RealEstateRequestDetailsModel> getRequestDetails(int id) async {
    try {
      final res = await _api.get(ApiConstants.realEstateRequestDetails(id));
      if (res is! Map || res['data'] is! Map) {
        throw AppException('Unexpected response!');
      }
      return RealEstateRequestDetailsModel.fromJson(
        Map<String, dynamic>.from(res['data'] as Map),
      );
    } catch (e) {
      throw AppException('Failed to load request details: $e');
    }
  }
}