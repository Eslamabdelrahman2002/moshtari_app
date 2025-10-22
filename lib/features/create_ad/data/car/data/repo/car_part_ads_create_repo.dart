import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';

import '../model/car_part_ad_request.dart';
import '../model/car_part_ad_response.dart';

class CarPartAdsCreateRepo {
  final Dio _dio;
  CarPartAdsCreateRepo(this._dio);

  Future<CarPartAdResponse> createCarPartAd(CarPartAdRequest req) async {
    // FormData جديد عند كل محاولة
    Future<Response> _post(String path) async {
      final form = await req.toFormData();
      return _dio.post(
        '${ApiConstants.baseUrl}$path',
        data: form,
        options: Options(
          validateStatus: (s) => s != null && s < 500,
          headers: {'Accept': 'application/json'},
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
          extra: {
            'noRetry': true, // لو عندك RetryInterceptor
            'retry': false,
          },
        ),
      );
    }

    // المسار الأساسي
    Response res = await _post(ApiConstants.carPartAdsCreate);

    // فولباك لمسار بديل في بعض البيئات
    if (res.statusCode == 404 || res.statusCode == 405) {
      res = await _post('car-part-ads/car-part-ads');
    }

    if (res.statusCode != null && res.statusCode! ~/ 100 == 2) {
      final Map<String, dynamic> data =
      res.data is Map ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};
      return CarPartAdResponse.fromJson(data);
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'فشل إنشاء الإعلان (${res.statusCode})';
    throw Exception(msg);
  }
}