import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import '../model/other_ad_request.dart';


class OtherAdsCreateRepo {
  final Dio dio;
  OtherAdsCreateRepo(this.dio);

  Future<Response> createOtherAd(OtherAdRequest req) async {
    final data = await req.toFormData();
    return await dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.otherAds}',
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}