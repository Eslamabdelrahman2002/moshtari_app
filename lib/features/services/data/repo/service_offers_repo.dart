// lib/features/services/data/repo/service_offers_repo.dart
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

class ServiceOffersRepo {
  final ApiService _api;
  ServiceOffersRepo(this._api);

  Future<Map<String, dynamic>> sendOffer({
    required int requestId,
    required num price,
    String? message,
  }) async {
    final data = {
      'request_id': requestId,
      'price': price,
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    };

    // مهم: ApiService.post يستقبل البودي كـ positional parameter
    final res = await _api.post(ApiConstants.serviceOffers, data,requireAuth: true);
    return res is Map<String, dynamic> ? res : {'success': true, 'data': res};
  }
}