// lib/features/trips/data/repo/dyna_trips_repo.dart
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../../../services/data/model/dinat_trip.dart';
import '../model/dyna_trip_models.dart';
import '../model/dyna_trips_list_models.dart';
// ملاحظة: يجب أن تتأكد من أن DynaTripsResponse موجود في أحد ملفات الـ model أعلاه.

class DynaTripsRepo {
  final ApiService _api;
  DynaTripsRepo(this._api);

  // ✅ وظيفة جلب الرحلات المتاحة (تم دمجها من DynaTripRepo)
  Future<DynaTripsResponse> fetchAvailable({int page = 1, int limit = 10}) async {
    final res = await _api.get(
      ApiConstants.dynaTripsAvailable,
      queryParameters: {'page': page, 'limit': limit},
    );
    // نفترض أن DynaTripsResponse هو الكلاس الصحيح الذي تم استيراده من ملف الـ model
    return DynaTripsResponse.fromJson(res);
  }

  Future<DynaTripsListResponse> fetchTrips({
    required int page,
    required int pageSize,
    int? fromCityId,
    int? toCityId,
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (fromCityId != null) 'from_city_id': fromCityId,
      if (toCityId != null) 'to_city_id': toCityId,
    };
    final res = await _api.get(ApiConstants.dynaTrips, queryParameters: qp);
    return DynaTripsListResponse.fromJson(res as Map<String, dynamic>);
  }

  Future<DynaTripsListResponse> fetchMyTrips({
    required int page,
    required int pageSize,
    int? fromCityId,
    int? toCityId,
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (fromCityId != null) 'from_city_id': fromCityId,
      if (toCityId != null) 'to_city_id': toCityId,
    };
    final res = await _api.get(ApiConstants.dynaMyTrips, queryParameters: qp);
    return DynaTripsListResponse.fromJson(res as Map<String, dynamic>);
  }

  Future<DynaTripCreateResponse> addTrip(DynaTripCreateRequest req) async {
    final res = await _api.post(ApiConstants.dynaTripsAdd, req.toJson());
    return DynaTripCreateResponse.fromJson(res as Map<String, dynamic>);
  }
}