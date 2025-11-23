import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/received_offer_models.dart';

class ReceivedOffersRepo {
  final ApiService _api;
  ReceivedOffersRepo(this._api);

  // جلب العروض المستلمة
  Future<List<ReceivedOffer>> fetchMyReceivedOffers() async {
    final res = await _api.get(
      ApiConstants.serviceRequestsMyReceivedOffers,
      requireAuth: true,
    );
    final parsed = MyReceivedOffersResponse.fromJson(res as Map<String, dynamic>);
    return parsed.offers;
  }

  // قبول عرض - يرجع حالة الطلب (request_status) إن وُجدت
  Future<String?> acceptOffer(int offerId) async {
    final res = await _api.post(
      ApiConstants.serviceOfferAccept(offerId),
      const {},
      requireAuth: true,
    );
    try {
      final data = (res['data'] as Map?) ?? const {};
      return data['request_status']?.toString(); // e.g., "in_progress"
    } catch (_) {
      return null;
    }
  }

  // رفض عرض
  Future<void> rejectOffer(int offerId) async {
    await _api.post(
      ApiConstants.serviceOfferReject(offerId),
      const {},
      requireAuth: true,
    );
  }

  // (اختياري) إنشاء عرض (للمزوّد)
  // POST /api/service-offers/offers
  // body: { "request_id": 36, "price": 4000, "message": "..." }
  Future<ReceivedOffer?> createOffer({
    required int requestId,
    required num price,
    String? message,
  }) async {
    final body = {
      'request_id': requestId,
      'price': price,
      if (message != null && message.trim().isNotEmpty) 'message': message,
    };

    final res = await _api.post(
      ApiConstants.serviceOffers,
      body,
      requireAuth: true,
    );

    try {
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return ReceivedOffer.fromJson(data);
      } else if (data is List && data.isNotEmpty) {
        return ReceivedOffer.fromJson((data.first as Map).cast<String, dynamic>());
      }
    } catch (_) {}
    return null;
  }
}