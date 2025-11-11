// lib/features/real_estate_ads/data/repo/real_estate_ads_repo.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

import '../model/real_estate_ad_request.dart';
import '../model/real_estate_ad_response.dart';

class RealEstateAdsRepo {
  final ApiService _api = getIt<ApiService>();

  Future<RealEstateAdResponse> createRealEstateAd(
      RealEstateAdRequest req) async {
    final fields = req.toMap();

    // تأكد إن السرويسز لو موجودة تتحوّل JSON (كما في الأصلي)
    if (fields['services'] != null) {
      fields['services'] = jsonEncode(fields['services']);
    }

    // تجهيز الملفات
    final images = <MultipartFile>[];
    for (final f in req.images) {
      images.add(await MultipartFile.fromFile(
        f.path,
        filename: p.basename(f.path),
      ));
    }

    // إعداد الـ FormData
    final form = FormData.fromMap({
      ...fields,
      if (images.isNotEmpty)
        ApiConstants.realEstateImagesKey: images,
    });

    // استخدم ApiService.postForm (كما في الأصلي)
    final data = await _api.postForm(
      ApiConstants.realEstateCreateAd,
      form,
      requireAuth: true, // ✅ التوكن مطلوب
    );

    // تحليل الاستجابة
    if (data is Map<String, dynamic>) {
      return RealEstateAdResponse.fromJson(data);
    }

    return RealEstateAdResponse(
        success: true, message: 'تم الإرسال', id: null);
  }

  // إضافة UPDATE (جديد)
  Future<RealEstateAdResponse> updateRealEstateAd(
      int id,
      RealEstateAdRequest req,
      ) async {
    final fields = req.toMap();

    // الخدمات تُرسل JSON string (كما في CREATE)
    if (fields['services'] != null) {
      fields['services'] = jsonEncode(fields['services']);
    }

    // Logging للتصحيح
    debugPrint('[Repo] Update fields: $fields');

    // PUT مع JSON (بدون FormData، لأن UPDATE لا يدعم صور)
    final data = await _api.put(
      ApiConstants.updateRealEstateAd(id),
      data: fields,
      requireAuth: true,
    );

    if (data is Map<String, dynamic>) {
      return RealEstateAdResponse.fromJson(data);
    }
    return RealEstateAdResponse(success: true, message: 'تم التحديث', id: id);
  }
}