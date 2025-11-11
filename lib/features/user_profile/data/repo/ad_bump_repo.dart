import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

class AdsBumpRepo {
  final ApiService _api;
  AdsBumpRepo(this._api);
  
  Future<void> bumpAd({required String adType, required int adId}) async {
    final endpoint = ApiConstants.bumpAdPath(adType: adType, id: adId);
    await _api.put(
      endpoint,
      data: {'_action': 'bump'},
      requireAuth: true,
    );
  }
}