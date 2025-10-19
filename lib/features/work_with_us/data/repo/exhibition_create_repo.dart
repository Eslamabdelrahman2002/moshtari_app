import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/api_constants.dart';

class ExhibitionCreateRepo {
  final ApiService _api;
  ExhibitionCreateRepo(this._api);

  Future<void> create({
    required String name,
    required String email,
    required String activityType, // 'car_ad' | 'real_estate_ad' | 'car_part_ad'
    required String phoneNumber,
    required String address,
    required int cityId,
    required int regionId,
    required File image,
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'email': email,
      'activity_type': activityType,
      'phone_number': phoneNumber,
      'address': address,
      'city_id': cityId,
      'region_id': regionId,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: p.basename(image.path),
      ),
    });
    await _api.postForm(ApiConstants.exhibitions, form);
  }
}