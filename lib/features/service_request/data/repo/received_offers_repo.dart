import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/received_offer_models.dart';

class ReceivedOffersRepo {
  final ApiService _api;
  ReceivedOffersRepo(this._api);

  Future<List<ReceivedOffer>> fetchMyReceivedOffers() async {
    final res = await _api.get(ApiConstants.serviceRequestsMyReceivedOffers);
    final parsed = MyReceivedOffersResponse.fromJson(res as Map<String, dynamic>);
    return parsed.offers;
  }

  // NEW: قبول العرض
  Future<String?> acceptOffer(int offerId) async {
    final res = await _api.post(ApiConstants.serviceOfferAccept(offerId), const {});
    // يحترم بنية الاستجابة كما في Postman
    try {
      final data = (res['data'] as Map?) ?? const {};
      return data['request_status']?.toString(); // غالباً in_progress
    } catch (_) {
      return null;
    }
  }
}