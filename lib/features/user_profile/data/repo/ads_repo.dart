import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

class AdsRepo {
  final ApiService _api;
  AdsRepo(this._api);

  // adType: 'car' | 'real_estate' | 'car_part' | 'other'
  Future<void> deleteAd({required String adType, required int id}) async {
    final path = ApiConstants.deleteAdPath(adType: adType, id: id);
    await _api.deleteWithBody(path);
  }

  // بدائل محددة النوع (اختياري)
  Future<void> deleteCarAd(int id) => _api.deleteWithBody(ApiConstants.deleteCarAd(id),requireAuth: true);
  Future<void> deleteRealEstateAd(int id) => _api.deleteWithBody(ApiConstants.deleteRealEstateAd(id),requireAuth: true);
  Future<void> deleteCarPartAd(int id) => _api.deleteWithBody(ApiConstants.deleteCarPartAd(id),requireAuth: true);
  Future<void> deleteOtherAd(int id) => _api.deleteWithBody(ApiConstants.deleteOtherAd(id),requireAuth: true);
}