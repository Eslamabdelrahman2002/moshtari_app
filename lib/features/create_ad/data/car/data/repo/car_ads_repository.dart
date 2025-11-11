import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

import '../../../../../../core/api/api_constants.dart';
import '../../../../../../core/api/api_service.dart';
import '../model/car_ad_request.dart';
import 'car_ad_response.dart';

class CarAdsRepository {
  final ApiService _apiService;
  CarAdsRepository(this._apiService);
  double _normalizeLat(double? v) {
    if (v == null || v < -90 || v > 90) return 24.774265;
    // لو السيرفر لا يقبل السالب
    if (v < 0) return 24.774265;
    return v;
  }

  double _normalizeLng(double? v) {
    if (v == null || v < -180 || v > 180) return 46.738586;
    // لو السيرفر لا يقبل السالب
    if (v < 0) return 46.738586;
    return v;
  }

  // إنشاء إعلان سيارات (مطابق لـ Postman)
  Future<CarAdResponse> createCarAd(CarAdRequest request) async {
    final raw = request.toMap();

    // 1) category_id = 5 كما في استجابة Postman
    raw['category_id'] = 5;

    // 2) تحويل phone -> phone_number
    final phone = raw.remove('phone');
    if (phone != null) {
      raw['phone_number'] = phone;
    }

    // 3) تطبيع الإحداثيات وتحويلها لنص بالدقة المطلوبة
    raw['latitude']  = _normalizeLat(request.latitude).toStringAsFixed(8);
    raw['longitude'] = _normalizeLng(request.longitude).toStringAsFixed(8);

    // 4) بناء FormData يدوياً كحقول نصية + ملفات
    final form = FormData();

    void addField(String k, dynamic v) {
      if (v != null) form.fields.add(MapEntry(k, v.toString()));
    }

    raw.forEach(addField);

    // 5) الصور تحت image_urls (متكرر لكل صورة)
    for (final f in request.images) {
      form.files.add(
        MapEntry(
          ApiConstants.carImagesKey, // يجب أن يكون 'image_urls'
          await MultipartFile.fromFile(
            f.path,
            filename: p.basename(f.path),
          ),
        ),
      );
    }

    // 6) تقرير الفحص
    if (request.technicalReport != null) {
      form.files.add(
        MapEntry(
          ApiConstants.carTechnicalReportKey, // 'technical_report'
          await MultipartFile.fromFile(
            request.technicalReport!.path,
            filename: p.basename(request.technicalReport!.path),
          ),
        ),
      );
    }

    // Debug واضح
    try {
      debugPrint('[CarRepo][CREATE] endpoint = ${ApiConstants.carAdsCreate}');
      for (final f in form.fields) {
        debugPrint('[CarRepo][CREATE] field: ${f.key}=${f.value}');
      }
      debugPrint('[CarRepo][CREATE] files: ${form.files.length}');
      for (final f in form.files) {
        debugPrint('[CarRepo][CREATE] file key: ${f.key}');
      }

      final resData = await _apiService.postForm(
        ApiConstants.carAdsCreate, // '/car-ads/car-ads'
        form,
        requireAuth: true,
      );

      // اطبع الاستجابة لو حبيت
      if (resData is Map<String, dynamic>) {
        debugPrint('[CarRepo][CREATE] response: $resData');
        return CarAdResponse.fromJson(resData);
      }
      debugPrint('[CarRepo][CREATE] response (non-map): $resData');
      return CarAdResponse(success: true, message: 'تم الإرسال', id: null);
    } on DioException catch (e) {
      // اطبع حالة الاستجابة وجسمها للمزيد من التشخيص
      debugPrint('[CarRepo][CREATE][DioException] status=${e.response?.statusCode}');
      debugPrint('[CarRepo][CREATE][DioException] body=${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('[CarRepo][CREATE] Unexpected error: $e');
      rethrow;
    }
  }
  // UPDATE: جديد (PUT JSON خفيف بدون ملفات)
  Future<CarAdResponse> updateCarAd(
      int id,
      CarAdRequest request, {
        List<String>? imageUrls, // صور قديمة (اختياري)
      }) async {
    // whitelist للحقول الآمنة فقط في PUT
    final Map<String, dynamic> body = {
      'title': request.title,
      'description': request.description,
      'price_type': request.priceType,
      if (request.priceType == 'fixed') 'price': request.price, // السعر فقط لو fixed
      'city_id': request.cityId ?? 1,
      'region_id': request.regionId ?? 1,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'allow_comments': request.allowComments,
      'allow_marketing_offers': request.allowMarketing, // السيرفر يتوقع هذا المفتاح
      if (imageUrls != null) 'image_urls': imageUrls,   // Array من الروابط لو تحب تحتفظ بصور قديمة
    };

    // لا ترسل nulls أبداً
    body.removeWhere((k, v) => v == null);

    // Debug (اختياري):
    debugPrint('[CarRepo] PUT ${ApiConstants.updateCarAd(id)} => $body');

    final resData = await _apiService.put(
      ApiConstants.updateCarAd(id),
      data: body,
      requireAuth: true,
    );

    if (resData is Map<String, dynamic>) {
      return CarAdResponse.fromJson(resData);
    }
    return CarAdResponse(success: true, message: 'تم التحديث', id: id);
  }
}