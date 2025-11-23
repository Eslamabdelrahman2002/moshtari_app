import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/features/service_profile/data/model/received_offer.dart';

import '../model/service_provider_models.dart';
import '../model/service_request_models.dart';

class ServiceProviderRepo {
  final ApiService _api;
  ServiceProviderRepo(this._api);

  Future<ServiceProviderModel> fetchProvider(int id) async {
    final res = await _api.get(ApiConstants.serviceProviderProfile(id));
    return ServiceProviderModel.fromJson(
      (res as Map<String, dynamic>)['data'] ?? {},
    );
  }

  /// جلب طلبات الخدمة الخاصة بالمزوّد
  /// GET /api/service-provider/service-requests
  Future<List<ServiceRequest>> fetchServiceRequests() async {
    final res = await _api.get(ApiConstants.serviceProviderRequests);
    final parsed =
    ServiceRequestsResponse.fromJson(res as Map<String, dynamic>);
    return parsed.data;
  }

  /// (لم يعد يُستخدم في الـ UI لتجنّب 403)
  Future<void> updateRequestStatus(int requestId, String newStatus) async {
    await _api.post(
      ApiConstants.serviceProviderUpdateRequestStatus(requestId),
      {'new_status': newStatus},
      requireAuth: true,
    );
  }

  /// إرسال عرض (Submit) من المزوّد على طلب معيّن
  /// POST /api/service-offers/offers
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
      final data = (res as Map<String, dynamic>)['data'];
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

  /// العروض المستلمة (للعميل) – يمكن تبقيها كما هي لو تحتاجها في شاشة أخرى
  Future<List<ReceivedOffer>> fetchMyReceivedOffers() async {
    final res = await _api.get(ApiConstants.myReceivedOffers);
    final map = (res as Map<String, dynamic>);
    final data = map['data'];

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => ReceivedOffer.fromJson(e))
          .toList();
    } else if (data is Map<String, dynamic>) {
      return [ReceivedOffer.fromJson(data)];
    }
    return [];
  }
}