import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

import '../../../../../../core/api/api_constants.dart';
import '../model/car_part_ad_request.dart';
import '../model/car_part_ad_response.dart'; // علشان getIt

class CarPartAdsCreateRepo {
  final ApiService _api = getIt<ApiService>();

  Future<CarPartAdResponse> createCarPartAd(CarPartAdRequest req) async {
    final formData = await req.toFormData();

    final map = await _api.postForm(
      ApiConstants.carPartAdsCreate,
      formData,
      requireAuth: true, // ✅ هنا صح لأنها ضمن ApiService
    );

    return CarPartAdResponse.fromJson(map);
  }
}