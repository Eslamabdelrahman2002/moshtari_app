// lib/features/car_ads/data/repositories/car_ads_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

import '../../../../../../core/api/api_constants.dart';
import '../../../../../../core/api/api_service.dart';
import '../model/car_ad_request.dart';
import 'car_ad_response.dart';

class CarAdsRepository {
  final ApiService _apiService;
  CarAdsRepository(this._apiService);

  Future<CarAdResponse> createCarAd(CarAdRequest request) async {
    final fields = request.toMap();

    final images = <MultipartFile>[];
    for (final f in request.images) {
      // 🟢 يجب استخدام filename لضمان أن Dio يرسل الملف باسم مناسب
      images.add(await MultipartFile.fromFile(
        f.path,
        filename: p.basename(f.path),
      ));
    }

    // 🟢 يجب تعديل الطريقة التي يتم بها إضافة الصور المتعددة إلى FormData
    // يجب تمرير List<MultipartFile> مباشرة تحت المفتاح المطلوب (ApiConstants.carImagesKey).

    final formData = FormData.fromMap({
      ...fields,
      // 🟢 إرسال قائمة الملفات تحت المفتاح المناسب
      if (images.isNotEmpty)
        ApiConstants.carImagesKey: images,

      if (request.technicalReport != null)
        ApiConstants.carTechnicalReportKey: await MultipartFile.fromFile(
          request.technicalReport!.path,
          filename: p.basename(request.technicalReport!.path),
        ),
    });

    final resData = await _apiService.postForm(
      ApiConstants.carAdsCreate,
      formData,
    );

    if (resData is Map<String, dynamic>) {
      return CarAdResponse.fromJson(resData);
    }
    return CarAdResponse(success: true, message: 'تم الإرسال', id: null);
  }
}