import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/exhibitions_list_models.dart';

class ExhibitionsRepo {
  final ApiService _api;
  ExhibitionsRepo(this._api);

  Future<List<ExhibitionItem>> fetchAll() async {
    final res = await _api.get(ApiConstants.exhibitions,requireAuth: true);
    final parsed = ExhibitionsListResponse.fromJson(res as Map<String, dynamic>);
    return parsed.data;
  }
}