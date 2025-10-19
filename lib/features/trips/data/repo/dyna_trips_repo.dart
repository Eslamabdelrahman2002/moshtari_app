import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../model/dyna_trip_models.dart';
import '../model/dyna_trips_list_models.dart';


class DynaTripsRepo {
  final ApiService _api;
  DynaTripsRepo(this._api);
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