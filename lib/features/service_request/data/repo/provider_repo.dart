import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/received_offer_models.dart';

class ProviderRepo {
  final ApiService _api;
  ProviderRepo(this._api);

  /// 🔹 جلب العروض المستلمة
  Future<List<ReceivedOffer>> fetchMyReceivedOffers() async {
    final res = await _api.get(
      ApiConstants.serviceRequestsMyReceivedOffers,
      requireAuth: true, // ✅ وجد تأكيد التوكن
    );
    final parsed =
    MyReceivedOffersResponse.fromJson(res as Map<String, dynamic>);
    return parsed.offers;
  }

  /// 🔹 قبول عرض
  Future<void> acceptOffer(int offerId) async {
    final endpoint = ApiConstants.serviceOfferAccept(offerId);
    await _api.post(endpoint, const {}, requireAuth: true); // ✅
  }

  /// 🔹 رفض العرض (إن وُجد endpoint)
  Future<void> rejectOffer(int offerId) async {
    final endpoint = 'service-offers/offers/$offerId/reject';
    await _api.post(endpoint, const {}, requireAuth: true); // ✅
  }
}