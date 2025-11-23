// lib/features/services/data/model/dinat_trip.dart

class DynaTrip {
  final int id;
  final String dynaCapacity;
  final int fromCityId;
  final int toCityId;

  final String departureDateIso; // مثال: 2025-09-01T10:00:00.000Z
  final String arrivalDateIso;

  final String fromCityNameAr;
  final String toCityNameAr;
  final String? fromCityNameEn; // ليس موجوداً في الـ body الحالي، نجعله اختياري
  final String? toCityNameEn;

  final String providerName;
  final int providerId;
  final String providerPhone;
  final String providerImage; // قد يكون null في الـ body، نعيده كـ '' عند التحويل

  // الحقول الإضافية الموجودة في الـ body (اختيارية)
  final String? cargoType;     // cargo_type
  final String? vehicleSize;   // vehicle_size
  final String? scheduleType;  // schedule_type
  final String? routeStart;    // route_start
  final String? routeEnd;      // route_end
  final String? extraDetails;  // extra_details

  // حقول غير موجودة حالياً في الـ body لكن نُبقيها احتياطاً
  final String? price;
  final String? pickUpAddress;
  final String? dropOffAddress;

  const DynaTrip({
    required this.id,
    required this.dynaCapacity,
    required this.fromCityId,
    required this.toCityId,
    required this.departureDateIso,
    required this.arrivalDateIso,
    required this.fromCityNameAr,
    required this.toCityNameAr,
    required this.providerName,
    required this.providerId,
    required this.providerPhone,
    required this.providerImage,
    this.fromCityNameEn,
    this.toCityNameEn,
    this.cargoType,
    this.vehicleSize,
    this.scheduleType,
    this.routeStart,
    this.routeEnd,
    this.extraDetails,
    this.price,
    this.pickUpAddress,
    this.dropOffAddress,
  });

  // Getters مفيدة
  DateTime? get departureDate => DateTime.tryParse(departureDateIso);
  DateTime? get arrivalDate => DateTime.tryParse(arrivalDateIso);

  // Helpers
  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _asStr(dynamic v) => v?.toString() ?? '';
  static String? _asStrOrNull(dynamic v) => v == null ? null : v.toString();

  factory DynaTrip.fromJson(Map<String, dynamic> json) {
    return DynaTrip(
      id: _asInt(json['id']),
      dynaCapacity: _asStr(json['dyna_capacity']),
      fromCityId: _asInt(json['from_city_id']),
      toCityId: _asInt(json['to_city_id']),

      departureDateIso: _asStr(json['departure_date']),
      arrivalDateIso: _asStr(json['arrival_date']),

      fromCityNameAr: _asStr(json['from_city_name_ar']),
      toCityNameAr: _asStr(json['to_city_name_ar']),
      fromCityNameEn: _asStrOrNull(json['from_city_name_en']),
      toCityNameEn: _asStrOrNull(json['to_city_name_en']),

      providerName: _asStr(json['provider_name']),
      providerId: _asInt(json['provider_id']),
      providerPhone: _asStr(json['provider_phone']),
      providerImage: _asStr(json['provider_image']), // عندما تكون null يعيد ''

      // الحقول الإضافية
      cargoType: _asStrOrNull(json['cargo_type']),
      vehicleSize: _asStrOrNull(json['vehicle_size']),
      scheduleType: _asStrOrNull(json['schedule_type']),
      routeStart: _asStrOrNull(json['route_start']),
      routeEnd: _asStrOrNull(json['route_end']),
      extraDetails: _asStrOrNull(json['extra_details']),

      // احتياطي/غير موجود في هذا الـ body
      price: _asStrOrNull(json['price']),
      pickUpAddress: _asStrOrNull(json['pick_up_address']),
      dropOffAddress: _asStrOrNull(json['drop_off_address']),
    );
  }
}

// Response + Pagination كما هي
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