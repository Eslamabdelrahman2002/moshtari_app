import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart' as api;

import '../model/exhibition_create_models.dart';

class ExhibitionCreateRepo {
  final api.ApiService _service;

  ExhibitionCreateRepo(api.ApiService service) : _service = service;

  // استدعاء بسيط باستخدام ApiService مباشرة (لو محتاجه في أماكن تانية)
  Future<void> create({
    required String name,
    required String email,
    required String activityType,
    required String phoneNumber,
    required String address,
    required int cityId,
    required int regionId,
    required File image,
    // تم حذف: int? promoterId,
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'email': email,
      'activity_type': activityType,
      'phone_number': phoneNumber,
      'address': address,
      'city_id': cityId,
      'region_id': regionId,
      // تم حذف: if (promoterId != null) 'promoter_id': promoterId,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: p.basename(image.path),
      ),
    });
    await _service.postForm(ApiConstants.exhibitions, form);
  }

  // النسخة التي ترجع Response Model
  Future<ExhibitionCreateResponse> createExhibition(
      ExhibitionCreateRequest request) async {
    final form = await request.toFormData();
    final rawResponse = await _service.postForm(ApiConstants.exhibitions, form,
        requireAuth: true);

    // 📝 Print الـ Response الخام (أضف ده)
    print('==================================================');
    print('Raw API Response: $rawResponse');
    print('==================================================');

    return ExhibitionCreateResponse.fromJson(rawResponse);
  }
}