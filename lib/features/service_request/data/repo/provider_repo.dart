import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/received_offer_models.dart';

class ProviderRepo {
  final ApiService _api;
  ProviderRepo(this._api);

  // GET: عروض مستلمة (نفس اللي في ReceivedOffersRepo)
  Future<List<ReceivedOffer>> fetchMyReceivedOffers() async {
    final res = await _api.get(ApiConstants.serviceRequestsMyReceivedOffers);
    final parsed = MyReceivedOffersResponse.fromJson(res as Map<String, dynamic>);
    return parsed.offers;
  }

  // POST: قبول عرض
  Future<void> acceptOffer(int offerId) async {
    // مثال endpoint: /api/service-offers/offers/{id}/accept
    final endpoint = 'service-offers/offers/$offerId/accept';
    await _api.post(endpoint, const {});
  }

  // (اختياري) رفض عرض لو موجود عندك endpoint مشابه
  Future<void> rejectOffer(int offerId) async {
    // لو متوفر عندك endpoint للرفض، استبدل المسار
    final endpoint = 'service-offers/offers/$offerId/reject';
    await _api.post(endpoint, const {});
  }
}