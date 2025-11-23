// lib/features/services/data/model/dyna_trip_models.dart
import 'dart:convert';

class DynaTripCreateRequest {
  final int providerRequestId;          // provider_request_id
  final int fromCityId;                 // from_city_id
  final int toCityId;                   // to_city_id
  final String dynaCapacity;            // dyna_capacity (كـ String حسب body)
  final DateTime departureDate;         // departure_date
  final DateTime arrivalDate;           // arrival_date

  // حقول إضافية لتوافق الـ body
  final String cargoType;               // cargo_type
  final String vehicleSize;             // vehicle_size
  final String? extraDetails;           // extra_details
  final String scheduleType;            // schedule_type -> 'once' أو غيره
  final String routeStart;              // route_start
  final String routeEnd;                // route_end

  DynaTripCreateRequest({
    required this.providerRequestId,
    required this.fromCityId,
    required this.toCityId,
    required this.dynaCapacity,
    required this.departureDate,
    required this.arrivalDate,
    required this.cargoType,
    required this.vehicleSize,
    this.extraDetails,
    this.scheduleType = 'once',
    required this.routeStart,
    required this.routeEnd,
  });

  String _isoUtc(DateTime d) => d.toUtc().toIso8601String();

  Map<String, dynamic> toJson() {
    return {
      'provider_request_id': providerRequestId,
      'from_city_id': fromCityId,
      'to_city_id': toCityId,
      'dyna_capacity': dynaCapacity, // String
      'departure_date': _isoUtc(departureDate),
      'arrival_date': _isoUtc(arrivalDate),
      'cargo_type': cargoType,
      'vehicle_size': vehicleSize,
      if (extraDetails != null && extraDetails!.trim().isNotEmpty) 'extra_details': extraDetails,
      'schedule_type': scheduleType,
      'route_start': routeStart,
      'route_end': routeEnd,
    };
  }
}

class DynaTripCreateData {
  final int id;
  final int providerRequestId;
  final int fromCityId;
  final int toCityId;
  final String dynaCapacity;       // server يرجّعها كنص
  final DateTime departureDate;
  final DateTime arrivalDate;
  final DateTime? createdAt;
  final String? cargoType;
  final String? vehicleSize;
  final String? extraDetails;
  final String? scheduleType;
  final String? routeStart;
  final String? routeEnd;
  final String? fromCityNameAr;
  final String? toCityNameAr;
  final String? providerName;
  final String? providerImage;
  final String? providerPhone;

  DynaTripCreateData({
    required this.id,
    required this.providerRequestId,
    required this.fromCityId,
    required this.toCityId,
    required this.dynaCapacity,
    required this.departureDate,
    required this.arrivalDate,
    this.createdAt,
    this.cargoType,
    this.vehicleSize,
    this.extraDetails,
    this.scheduleType,
    this.routeStart,
    this.routeEnd,
    this.fromCityNameAr,
    this.toCityNameAr,
    this.providerName,
    this.providerImage,
    this.providerPhone,
  });

  factory DynaTripCreateData.fromJson(Map<String, dynamic> j) {
    DateTime? _parse(String? v) => (v == null || v.isEmpty) ? null : DateTime.tryParse(v);
    return DynaTripCreateData(
      id: (j['id'] ?? 0) as int,
      providerRequestId: (j['provider_request_id'] ?? 0) as int,
      fromCityId: (j['from_city_id'] ?? 0) as int,
      toCityId: (j['to_city_id'] ?? 0) as int,
      dynaCapacity: (j['dyna_capacity'] ?? '').toString(),
      departureDate: DateTime.parse(j['departure_date']),
      arrivalDate: DateTime.parse(j['arrival_date']),
      createdAt: _parse(j['created_at']?.toString()),
      cargoType: j['cargo_type']?.toString(),
      vehicleSize: j['vehicle_size']?.toString(),
      extraDetails: j['extra_details']?.toString(),
      scheduleType: j['schedule_type']?.toString(),
      routeStart: j['route_start']?.toString(),
      routeEnd: j['route_end']?.toString(),
      fromCityNameAr: j['from_city_name_ar']?.toString(),
      toCityNameAr: j['to_city_name_ar']?.toString(),
      providerName: j['provider_name']?.toString(),
      providerImage: j['provider_image']?.toString(),
      providerPhone: j['provider_phone']?.toString(),
    );
  }
}

class DynaTripCreateResponse {
  final bool success;
  final String? message;              // قد لا يرسلها السيرفر
  final DynaTripCreateData? data;

  DynaTripCreateResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory DynaTripCreateResponse.fromJson(Map<String, dynamic> j) {
    return DynaTripCreateResponse(
      success: j['success'] == true,
      message: j['message']?.toString(),
      data: (j['data'] is Map<String, dynamic>) ? DynaTripCreateData.fromJson(j['data']) : null,
    );
  }

  static DynaTripCreateResponse fromRaw(String raw) =>
      DynaTripCreateResponse.fromJson(json.decode(raw) as Map<String, dynamic>);
}