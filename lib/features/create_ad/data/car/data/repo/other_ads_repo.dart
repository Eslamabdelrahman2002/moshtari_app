import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import '../model/other_ad_request.dart';

class OtherAdsCreateRepo {
  final ApiService _api = getIt<ApiService>();

  Future<Response> createOtherAd(OtherAdRequest req) async {
    final formData = await req.toFormData();

    final data = await _api.postForm(
      ApiConstants.otherAds,
      formData,
      requireAuth: true,
    );

    return Response(
      requestOptions: RequestOptions(path: ApiConstants.otherAds),
      data: data,
      statusCode: 200,
    );
  }

  // ✅ تحديث كـ JSON (بدون ملفات)
  Future<Response> updateOtherAd({
    required int id,
    required String title,
    required String description,
    required String priceType,           // fixed | negotiable | auction
    num? price,                          // يُرسل فقط مع fixed
    required int cityId,
    required int regionId,
    bool? allowComments,
    bool? allowMarketingOffers,
    String? phoneNumber,
    List<String>? communicationMethods,  // Array
    List<String>? imageUrls,             // Array من الروابط (اختياري للحفاظ على الصور القديمة)
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

    final data = await _api.put(
      ApiConstants.updateOtherAd(id),
      data: body,
      requireAuth: true,
    );

    return Response(
      requestOptions: RequestOptions(path: ApiConstants.updateOtherAd(id)),
      data: data,
      statusCode: 200,
    );
  }
}