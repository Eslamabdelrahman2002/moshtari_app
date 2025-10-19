// features/work_with_us/data/repo/work_with_us_repo.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/api_constants.dart';

class WorkWithUsRepo {
  final ApiService _api;
  WorkWithUsRepo(this._api);

  Future<void> applyPromoter({
    required String fullName,
    required String phone,
    required String email,
    required int regionId,
    required int cityId,
    required String employmentStatus, // 'working' | 'available'
    required File idDocument,
    required String nationalId,
    required String birthDate, // yyyy-MM-dd
  }) async {
    final formData = FormData.fromMap({
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'region_id': regionId,
      'city_id': cityId,
      'employment_status': employmentStatus,
      'id_document': await MultipartFile.fromFile(
        idDocument.path,
        filename: p.basename(idDocument.path),
      ),
      'national_id': nationalId,
      'birth_date': birthDate,
    });

    await _api.postForm(ApiConstants.promoterApplicationsApply, formData);
  }
}