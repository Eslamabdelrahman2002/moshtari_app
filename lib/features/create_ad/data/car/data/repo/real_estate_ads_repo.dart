// lib/features/real_estate_ads/data/repo/real_estate_ads_repo.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../../../core/api/api_constants.dart';
import '../model/real_estate_ad_request.dart';
import '../model/real_estate_ad_response.dart';

class RealEstateAdsRepo {
  final Dio _dio;
  RealEstateAdsRepo(this._dio);

  Future<RealEstateAdResponse> createRealEstateAd(RealEstateAdRequest req) async {
    final fields = req.toMap();

    if (fields['services'] != null) {
      fields['services'] = jsonEncode(fields['services']);
    }

    final images = <MultipartFile>[];
    for (final f in req.images) {
      images.add(await MultipartFile.fromFile(
        f.path,
        filename: p.basename(f.path),
      ));
    }

    final form = FormData.fromMap({
      ...fields,
      if (images.isNotEmpty) ApiConstants.realEstateImagesKey: images,
    });

    final res = await _dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.realEstateCreateAd}',
      data: form,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    if (res.data is Map) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(res.data as Map);
      return RealEstateAdResponse.fromJson(data);
    }

    return RealEstateAdResponse(success: true, message: 'تم الإرسال', id: null);
  }
}