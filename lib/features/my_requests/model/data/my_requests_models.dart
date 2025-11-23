// lib/features/service_request/data/model/my_requests_models.dart
import 'dart:convert';

int _asInt(v) => v is int ? v : int.tryParse('$v') ?? 0;

class RequestOfferItem {
  final int offerId;
  final String price;         // نص كما في الـ API
  final String status;        // pending | accepted | rejected
  final int providerId;
  final String providerName;
  final String providerPhone;

  const RequestOfferItem({
    required this.offerId,
    required this.price,
    required this.status,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
  });

  RequestOfferItem copyWith({
    String? status,
  }) => RequestOfferItem(
    offerId: offerId,
    price: price,
    status: status ?? this.status,
    providerId: providerId,
    providerName: providerName,
    providerPhone: providerPhone,
  );

  factory RequestOfferItem.fromJson(Map<String, dynamic> j) => RequestOfferItem(
    offerId: _asInt(j['offer_id']),
    price: (j['price'] ?? '').toString(),
    status: (j['status'] ?? '').toString(),
    providerId: _asInt(j['provider_id']),
    providerName: (j['provider_name'] ?? '').toString(),
    providerPhone: (j['provider_phone'] ?? '').toString(),
  );
}

class ServiceRequestItem {
  final int requestId;
  final String description;
  final String requestStatus; // pending | in_progress | completed | cancelled
  final String serviceType;   // dyna | flatbed | tanker
  final String cityName;
  final List<RequestOfferItem> offers;

  const ServiceRequestItem({
    required this.requestId,
    required this.description,
    required this.requestStatus,
    required this.serviceType,
    required this.cityName,
    required this.offers,
  });

  ServiceRequestItem copyWith({
    String? requestStatus,
    List<RequestOfferItem>? offers,
  }) => ServiceRequestItem(
    requestId: requestId,
    description: description,
    requestStatus: requestStatus ?? this.requestStatus,
    serviceType: serviceType,
    cityName: cityName,
    offers: offers ?? this.offers,
  );

  factory ServiceRequestItem.fromJson(Map<String, dynamic> j) => ServiceRequestItem(
    requestId: _asInt(j['request_id']),
    description: (j['description'] ?? '').toString(),
    requestStatus: (j['request_status'] ?? '').toString(),
    serviceType: (j['service_type'] ?? '').toString(),
    cityName: (j['city_name'] ?? '').toString(),
    offers: (j['offers'] is List)
        ? (j['offers'] as List).map((e) => RequestOfferItem.fromJson(e as Map<String, dynamic>)).toList()
        : const <RequestOfferItem>[],
  );
}

class MyRequestsResponse {
  final bool success;
  final String? message;
  final List<ServiceRequestItem> requests;

  MyRequestsResponse({
    required this.success,
    required this.requests,
    this.message,
  });

  factory MyRequestsResponse.fromJson(Map<String, dynamic> j) {
    final list = <ServiceRequestItem>[];
    final raw = j['requests'];
    if (raw is List) {
      for (final e in raw) list.add(ServiceRequestItem.fromJson(e));
    }
    return MyRequestsResponse(
      success: j['success'] == true,
      message: (j['message'] ?? '').toString(),
      requests: list,
    );
  }

  static MyRequestsResponse fromRaw(String raw) =>
      MyRequestsResponse.fromJson(json.decode(raw));
}