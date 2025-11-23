// lib/features/service_request/data/repo/my_requests_repo.dart
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/features/my_requests/model/data/my_requests_models.dart';


class MyRequestsRepo {
  final ApiService _api;
  MyRequestsRepo(this._api);

  // الحصول على "طلباتي"
  Future<List<ServiceRequestItem>> fetchMyRequests() async {
    final res = await _api.get(
      ApiConstants.serviceRequestsMyRequests,
      requireAuth: true,
    );
    final parsed = MyRequestsResponse.fromJson(res as Map<String, dynamic>);
    return parsed.requests;
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
  Future<RequestOfferItem?> createOffer({
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
        return RequestOfferItem.fromJson(data);
      } else if (data is List && data.isNotEmpty) {
        return RequestOfferItem.fromJson((data.first as Map).cast<String, dynamic>());
      }
    } catch (_) {}
    return null;
  }
}