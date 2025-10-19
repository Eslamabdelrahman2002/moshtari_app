import 'dart:convert';

int _asInt(dynamic v) {
  if (v is int) return v;
  return int.tryParse('$v') ?? 0;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.tryParse('$v');
  } catch (_) {
    return null;
  }
}

class DynaTripItem {
  final int id;
  final int providerRequestId;
  final int fromCityId;
  final int toCityId;
  final int dynaCapacity;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final DateTime? createdAt;
  final String fromCityNameAr;
  final String toCityNameAr;

  DynaTripItem({
    required this.id,
    required this.providerRequestId,
    required this.fromCityId,
    required this.toCityId,
    required this.dynaCapacity,
    required this.departureDate,
    required this.arrivalDate,
    required this.createdAt,
    required this.fromCityNameAr,
    required this.toCityNameAr,
  });

  factory DynaTripItem.fromJson(Map<String, dynamic> j) {
    return DynaTripItem(
      id: _asInt(j['id']),
      providerRequestId: _asInt(j['provider_request_id']),
      fromCityId: _asInt(j['from_city_id']),
      toCityId: _asInt(j['to_city_id']),
      dynaCapacity: _asInt(j['dyna_capacity']),
      departureDate: _asDate(j['departure_date']),
      arrivalDate: _asDate(j['arrival_date']),
      createdAt: _asDate(j['created_at']),
      fromCityNameAr: (j['from_city_name_ar'] ?? '').toString(),
      toCityNameAr: (j['to_city_name_ar'] ?? '').toString(),
    );
  }
}

class DynaTripsPagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  DynaTripsPagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory DynaTripsPagination.fromJson(Map<String, dynamic> j) => DynaTripsPagination(
    total: _asInt(j['total']),
    page: _asInt(j['page']),
    pageSize: _asInt(j['pageSize']),
    totalPages: _asInt(j['totalPages']),
  );
}

class DynaTripsListResponse {
  final bool success;
  final List<DynaTripItem> data;
  final DynaTripsPagination pagination;

  DynaTripsListResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory DynaTripsListResponse.fromJson(Map<String, dynamic> j) {
    final list = <DynaTripItem>[];
    if (j['data'] is List) {
      for (final e in (j['data'] as List)) list.add(DynaTripItem.fromJson(e));
    }
    return DynaTripsListResponse(
      success: j['success'] == true,
      data: list,
      pagination: DynaTripsPagination.fromJson(j['pagination'] ?? {}),
    );
  }

  static DynaTripsListResponse fromRaw(String raw) =>
      DynaTripsListResponse.fromJson(json.decode(raw));
}