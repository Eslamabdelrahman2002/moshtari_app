import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/marketing_request_model.dart';

class MarketingRequestsRepo {
  final ApiService _api;
  MarketingRequestsRepo(this._api);

  Future<MarketingRequestModel> create({
    required int adId,
    required String message,
  }) async {
    final resp = await _api.post(requireAuth: true,ApiConstants.marketingRequests, {
      'ad_id': adId,
      'message': message,
    });
    final data = resp['data'] is Map ? Map<String, dynamic>.from(resp['data']) : resp;
    return MarketingRequestModel.fromJson(data);
  }
}