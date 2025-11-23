import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../../../services/data/model/dinat_trip.dart';
import '../model/dyna_trip_models.dart';
import '../model/dyna_trips_list_models.dart';

class DynaTripsRepo {
  final ApiService _api;
  DynaTripsRepo(this._api);

  // تنسيق التاريخ لصيغة yyyy-MM-dd
  String? _formatDate(DateTime? d) {
    if (d == null) return null;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, dynamic> _buildQueryParams({
    required int page,
    required int pageSize,
    int? fromCityId,
    int? toCityId,
    int? dynaCapacity,
    int? regionId,
    DateTime? date, // DateTime? ثم نحوله داخلياً
  }) {
    final qp = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (fromCityId != null) 'from_city_id': fromCityId,
      if (toCityId != null) 'to_city_id': toCityId,
      if (dynaCapacity != null) 'dyna_capacity': dynaCapacity,
      if (regionId != null) 'region_id': regionId,
    };
    final ds = _formatDate(date);
    if (ds != null) qp['date'] = ds;
    return qp;
  }

  // جلب الرحلات المتاحة + فلاتر اختيارية
  Future<DynaTripsResponse> fetchAvailable({
    int page = 1,
    int? pageSize,
    int? limit, // alias قديم
    int? fromCityId,
    int? toCityId,
    int? dynaCapacity,
    int? regionId,
    DateTime? date, // الآن تقبل DateTime?
  }) async {
    final effectivePageSize = pageSize ?? limit ?? 10;

    final res = await _api.get(
      ApiConstants.dynaTripsAvailable,
      queryParameters: _buildQueryParams(
        page: page,
        pageSize: effectivePageSize,
        fromCityId: fromCityId,
        toCityId: toCityId,
        dynaCapacity: dynaCapacity,
        regionId: regionId,
        date: date,
      ),
    );
    return DynaTripsResponse.fromJson(res as Map<String, dynamic>);
  }

  // جلب قائمة الرحلات مع نفس الفلاتر
  Future<DynaTripsListResponse> fetchTrips({
    required int page,
    required int pageSize,
    int? fromCityId,
    int? toCityId,
    int? dynaCapacity,
    int? regionId,
    DateTime? date, // DateTime?
  }) async {
    final res = await _api.get(
      ApiConstants.dynaTrips,
      queryParameters: _buildQueryParams(
        page: page,
        pageSize: pageSize,
        fromCityId: fromCityId,
        toCityId: toCityId,
        dynaCapacity: dynaCapacity,
        regionId: regionId,
        date: date,
      ),
    );
    return DynaTripsListResponse.fromJson(res as Map<String, dynamic>);
  }

  // جلب رحلاتي
  Future<DynaTripsListResponse> fetchMyTrips({
    required int page,
    required int pageSize,
    int? fromCityId,
    int? toCityId,
    int? dynaCapacity,
    int? regionId,
    DateTime? date, // DateTime?
  }) async {
    final res = await _api.get(
      ApiConstants.dynaMyTrips,
      queryParameters: _buildQueryParams(
        page: page,
        pageSize: pageSize,
        fromCityId: fromCityId,
        toCityId: toCityId,
        dynaCapacity: dynaCapacity,
        regionId: regionId,
        date: date,
      ),
      requireAuth: true,
    );
    return DynaTripsListResponse.fromJson(res as Map<String, dynamic>);
  }

  Future<DynaTripCreateResponse> addTrip(DynaTripCreateRequest req) async {
    final res = await _api.post(
      ApiConstants.dynaTripsAdd,
      req.toJson(),
      requireAuth: true,
    );
    return DynaTripCreateResponse.fromJson(res as Map<String, dynamic>);
  }
  Future<void> updateTrip(int id, Map<String, dynamic> data) async {
    await _api.put(
      ApiConstants.dynaTripById(id),
      requireAuth: true,
    );
  }

  // ============================================
  // 🔴 حذف رحلة (DELETE)
  // ============================================
  Future<void> deleteTrip(int id) async {
    await _api.deleteWithBody(
      ApiConstants.dynaTripById(id),  // مثلاً: /api/dyna-trips/3
      requireAuth: true,
    );
  }
}