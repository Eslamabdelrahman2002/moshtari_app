// lib/features/create_ad/data/car/data/repo/car_part_ads_create_repo.dart
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';

import '../model/car_part_ad_request.dart';
import '../model/car_part_ad_response.dart';

class CarPartAdsCreateRepo {
  final Dio _dio;
  CarPartAdsCreateRepo(this._dio);

  Future<CarPartAdResponse> createCarPartAd(CarPartAdRequest req) async {
    final form = await req.toFormData();

    final res = await _dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.carPartAdsCreate}', // => /api/car-part-ads
      data: form,
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
        contentType: 'multipart/form-data',
      ),
    );

    if (res.statusCode != null && res.statusCode! ~/ 100 == 2) {
      final Map<String, dynamic> data =
      res.data is Map ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};
      return CarPartAdResponse.fromJson(data);
    } else {
      throw Exception('فشل إنشاء الإعلان (${res.statusCode})');
    }
  }
}