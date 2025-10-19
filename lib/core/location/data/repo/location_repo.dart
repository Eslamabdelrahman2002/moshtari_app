import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart' as api;
import 'package:mushtary/core/location/data/model/location_models.dart';


class LocationRepo {
  final api.ApiService _api;
  LocationRepo(this._api);

  Future<List<Region>> fetchRegions() async {
    final data = await _api.get(ApiConstants.regions);
    return Region.parseList(data);
  }

  Future<List<City>> fetchCities(int regionId) async {
    final data = await _api.get(ApiConstants.cities, queryParameters: {'region_id': regionId});
    return City.parseList(data);
  }
}