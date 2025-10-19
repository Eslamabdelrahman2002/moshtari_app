import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../model/exhibition_details_models.dart';


class ExhibitionDetailsRepo {
  final ApiService _api;
  ExhibitionDetailsRepo(this._api);

  Future<ExhibitionDetailsData> fetchById(int id) async {
    final res = await _api.get(ApiConstants.exhibitionDetailsById(id));
    final parsed = ExhibitionDetailsResponse.fromJson(res as Map<String, dynamic>);
    return parsed.data;
  }
}