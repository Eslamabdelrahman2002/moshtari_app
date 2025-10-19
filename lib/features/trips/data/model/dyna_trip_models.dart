import 'dart:convert';

class DynaTripCreateRequest {
  final int providerId;
  final int fromCityId;
  final int toCityId;
  final int dynaCapacity;
  final DateTime departureDate;
  final DateTime arrivalDate;

  DynaTripCreateRequest({
    required this.providerId,
    required this.fromCityId,
    required this.toCityId,
    required this.dynaCapacity,
    required this.departureDate,
    required this.arrivalDate,
  });

  Map<String, dynamic> toJson() {
    // نفس صيغة الـ JSON المطلوبة "yyyy-MM-ddTHH:mm:ss"
    String fmt(DateTime d) => d.toIso8601String().split('.').first;
    return {
      'provider_id': providerId,
      'from_city_id': fromCityId,
      'to_city_id': toCityId,
      'dyna_capacity': dynaCapacity,
      'departure_date': fmt(departureDate),
      'arrival_date': fmt(arrivalDate),
    };
  }
}

class DynaTripCreateResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  DynaTripCreateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DynaTripCreateResponse.fromJson(Map<String, dynamic> j) {
    return DynaTripCreateResponse(
      success: j['success'] == true,
      message: (j['message'] ?? '').toString(),
      data: j['data'] is Map<String, dynamic> ? (j['data'] as Map<String, dynamic>) : null,
    );
  }

  static DynaTripCreateResponse fromRaw(String raw) =>
      DynaTripCreateResponse.fromJson(json.decode(raw));
}