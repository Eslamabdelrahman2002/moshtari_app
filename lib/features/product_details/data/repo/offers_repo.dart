// lib/features/offers/data/repo/offers_repo.dart
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/offer_request.dart';
import '../model/offer_details.dart';

class OffersRepo {
  final ApiService _apiService;
  OffersRepo(this._apiService);

  Future<String> submitOffer(OfferRequest request) async {
    final res = await _apiService.post(ApiConstants.submitOffer, request.toMap(),requireAuth: true);
    if (res is Map<String, dynamic>) {
      return (res['message'] ?? 'تم إرسال عرض المساومة بنجاح.').toString();
    }
    return 'تم إرسال عرض المساومة بنجاح.';
  }

  Future<OfferDetails> getOfferById(int id) async {
    final res = await _apiService.get(ApiConstants.offerById(id),requireAuth: true);
    final Map<String, dynamic> data =
    (res is Map && res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'])
        : (res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{});
    return OfferDetails.fromJson(data);
  }
}