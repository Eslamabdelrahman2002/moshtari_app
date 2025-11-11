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
      requireAuth: true,
    );
    return CarPartAdResponse.fromJson(map);
  }

  // لو عندك هذه الدالة، تأكد من استخدامها بالمسار الصحيح:
  Future<CarPartAdResponse> updateCarPartAd(
      int id, {
        required String title,
        required String description,
        required String priceType,
        num? price,
        required int cityId,
        required int regionId,
        bool? allowComments,
        bool? allowMarketingOffers,
        String? phoneNumber,
        List<String>? communicationMethods,
        List<String>? imageUrls,
        double? latitude,
        double? longitude,
      }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'price_type': priceType,
      if (priceType == 'fixed' && price != null) 'price': price,
      'city_id': cityId,
      'region_id': regionId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (allowComments != null) 'allow_comments': allowComments,
      if (allowMarketingOffers != null) 'allow_marketing_offers': allowMarketingOffers,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (communicationMethods != null) 'communication_methods': communicationMethods,
      if (imageUrls != null) 'image_urls': imageUrls,
    }..removeWhere((k, v) => v == null);

    final map = await _api.put(
      ApiConstants.carPartAdsUpdate(id), // ✅ مسار الباك كما هو
      data: body,
      requireAuth: true,
    );
    return CarPartAdResponse.fromJson(map);
  }
}