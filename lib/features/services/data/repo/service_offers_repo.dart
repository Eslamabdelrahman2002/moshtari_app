import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/features/service_profile/data/model/received_offer.dart';

class ServiceOffersRepo {
  final ApiService _api;
  ServiceOffersRepo(this._api);

  /// إنشاء عرض (Submit offer)
  /// POST /api/service-offers/offers
  /// body: { "request_id": ..., "price": ..., "message": ...? }
  Future<ReceivedOffer?> submitOffer({
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
        return ReceivedOffer.fromJson(
          (data.first as Map).cast<String, dynamic>(),
        );
      }
    } catch (_) {}
    return null;
  }

  /// قبول عرض
  /// POST /api/service-offers/offers/{offerId}/accept
  Future<void> acceptOffer(int offerId) async {
    await _api.post(
      ApiConstants.serviceOfferAccept(offerId),
      const {},
      requireAuth: true,
    );
  }

  /// رفض عرض
  /// POST /api/service-offers/offers/{offerId}/reject
  Future<void> rejectOffer(int offerId) async {
    await _api.post(
      ApiConstants.serviceOfferReject(offerId),
      const {},
      requireAuth: true,
    );
  }
}