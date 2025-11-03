import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse('$v') ?? 0;
}

class ExhibitionCreateRequest {
  final String name;
  final String email;
  final String activityType; // 'car_ad' | 'real_estate_ad' | 'car_part_ad'
  final String phoneNumber;
  final String address;
  final int cityId;
  final int regionId;
  // تم حذف: final int? promoterId; // الاعتماد على التوكن فقط
  final File image;

  ExhibitionCreateRequest({
    required this.name,
    required this.email,
    required this.activityType,
    required this.phoneNumber,
    required this.address,
    required this.cityId,
    required this.regionId,
    required this.image,
    // تم حذف: this.promoterId,
  });

  Future<FormData> toFormData() async {
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

    // 📝 Print الـ FormData fields (أضف ده للـ debug)
    print('==================================================');
    print('FormData Prepared for API:');
    print('name: ${form.fields.firstWhere((f) => f.key == 'name', orElse: () => MapEntry('', ''))?.value}');
    print('email: ${form.fields.firstWhere((f) => f.key == 'email', orElse: () => MapEntry('', ''))?.value}');
    print('activity_type: ${form.fields.firstWhere((f) => f.key == 'activity_type', orElse: () => MapEntry('', ''))?.value}');
    print('phone_number: ${form.fields.firstWhere((f) => f.key == 'phone_number', orElse: () => MapEntry('', ''))?.value}');
    print('address: ${form.fields.firstWhere((f) => f.key == 'address', orElse: () => MapEntry('', ''))?.value}');
    print('city_id: ${form.fields.firstWhere((f) => f.key == 'city_id', orElse: () => MapEntry('', ''))?.value}');
    print('region_id: ${form.fields.firstWhere((f) => f.key == 'region_id', orElse: () => MapEntry('', ''))?.value}');
    // 📝 التصحيح هنا: استخدم form.files.first.value.filename (value هو MultipartFile)
    print('image filename: ${form.files.isNotEmpty ? form.files.first.value.filename : 'None'}');
    print('==================================================');

    return form;
  }
}

class ExhibitionCreateResponse {
  final bool success;
  final String message;
  final int? id;

  ExhibitionCreateResponse({
    required this.success,
    required this.message,
    this.id,
  });

  factory ExhibitionCreateResponse.fromJson(Map<String, dynamic> j) {
    final msg = (j['message'] ?? j['msg'] ?? '').toString();
    int? id;
    if (j['data'] is Map<String, dynamic>) {
      id = _asInt((j['data'] as Map<String, dynamic>)['id']);
    } else if (j['id'] != null) {
      id = _asInt(j['id']);
    }
    return ExhibitionCreateResponse(
      success: j['success'] == true || j['status'] == true,
      message: msg,
      id: id,
    );
  }

  static ExhibitionCreateResponse fromRaw(String raw) =>
      ExhibitionCreateResponse.fromJson(json.decode(raw));
}