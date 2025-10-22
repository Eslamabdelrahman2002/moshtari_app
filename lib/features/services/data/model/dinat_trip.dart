// lib/features/services/data/model/dyna_trip.dart
class DynaTrip {
  final int id;
  final String dynaCapacity; // كنص كما يأتي من الـ API
  final int fromCityId;
  final int toCityId;
  final String departureDateIso;
  final String arrivalDateIso;
  final String fromCityNameAr;
  final String fromCityNameEn;
  final String toCityNameAr;
  final String toCityNameEn;
  final String providerName;
  final int providerId;
  final String providerImage;
  final String providerPhone;

  const DynaTrip({
    required this.id,
    required this.dynaCapacity,
    required this.fromCityId,
    required this.toCityId,
    required this.departureDateIso,
    required this.arrivalDateIso,
    required this.fromCityNameAr,
    required this.fromCityNameEn,
    required this.toCityNameAr,
    required this.toCityNameEn,
    required this.providerName,
    required this.providerId,
    required this.providerImage,
    required this.providerPhone,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _asStr(dynamic v) => v?.toString() ?? '';

  factory DynaTrip.fromJson(Map<String, dynamic> json) {
    return DynaTrip(
      id: _asInt(json['id']),
      dynaCapacity: _asStr(json['dyna_capacity']),
      fromCityId: _asInt(json['from_city_id']),
      toCityId: _asInt(json['to_city_id']),
      departureDateIso: _asStr(json['departure_date']),
      arrivalDateIso: _asStr(json['arrival_date']),
      fromCityNameAr: _asStr(json['from_city_name_ar']),
      fromCityNameEn: _asStr(json['from_city_name_en']),
      toCityNameAr: _asStr(json['to_city_name_ar']),
      toCityNameEn: _asStr(json['to_city_name_en']),
      providerName: _asStr(json['provider_name']),
      providerId: _asInt(json['provider_id']),
      providerImage: _asStr(json['provider_image']),
      providerPhone: _asStr(json['provider_phone']),
    );
  }
}

// lib/features/services/data/model/dyna_trips_response.dart
class DynaTripsResponse {
  final List<DynaTrip> data;
  final Pagination pagination;

  DynaTripsResponse({required this.data, required this.pagination});

  factory DynaTripsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .map((e) => DynaTrip.fromJson(e as Map<String, dynamic>))
        .toList();
    final pag = Pagination.fromJson(json['pagination'] as Map<String, dynamic>? ?? {});
    return DynaTripsResponse(data: list, pagination: pag);
  }
}

class Pagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const Pagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: _asInt(json['total']),
      page: _asInt(json['page']),
      pageSize: _asInt(json['pageSize']),
      totalPages: _asInt(json['totalPages']),
    );
  }
}