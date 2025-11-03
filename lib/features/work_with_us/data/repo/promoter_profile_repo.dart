import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../model/promoter_profile_models.dart';


class PromoterProfileRepo {
  final ApiService _api;
  PromoterProfileRepo(this._api);

  Future<PromoterProfileData> fetchProfile() async {
    final res = await _api.get(ApiConstants.promoterApplicationsProfile,requireAuth: true);
    final parsed = PromoterProfileResponse.fromJson(res as Map<String, dynamic>);
    return parsed.data;
  }
}