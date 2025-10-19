// lib/features/services/data/models/service_registration_model.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// تعريف النموذج الذي يحمل بيانات التسجيل من جميع الخطوات
class ServiceProviderRegistrationModel {
  // بيانات عامة
  String serviceType; // (مثال: 'ajir', 'dyna', 'satha', 'tanker')
  String? fullName;
  String? idNumber;
  String? birthDate; // صيغة YYYY-MM-DD
  String? nationality;
  String? phone;

  // الموقع
  double? latitude;
  double? longitude;
  String? city;
  String? district;
  String? fullAddress;

  // تفاصيل العامل (اجير)
  String? specialization;
  String? experienceDescription;
  bool? hasTransportation;

  // تفاصيل النقل (دينت/سطحة/صهريج)
  String? vehicleType; // (ماركة السيارة: تويوتا، فورد...)
  String? vehicleModel; // (الموديل/السنة)
  String? vehiclePlateNumber;
  String? cargoDescription; // (وصف الحمولة لـ transport/dyna)
  String? plateLetters; // (لـ tanker)
  String? plateNumbers; // (لـ tanker)
  String? tankerSize; // (لـ tanker)
  String? tankerServices; // (لـ tanker - تلخيص الخدمات)


  // الملفات (Images) - يجب أن تكون من نوع File أو MultipartFile عند الإرسال
  File? personalImage;
  File? idImage;
  File? frontImage;
  File? backImage;
  File? licenseImage;
  List<File>? extraImages;

  ServiceProviderRegistrationModel({
    required this.serviceType,
  });

  // تحويل النموذج إلى FormData للإرسال إلى API
  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'service_type': serviceType,
      // البيانات الشخصية (مستخدمة في جميع الأنواع)
      'full_name': fullName,
      'id_number': idNumber,
      'birth_date': birthDate,
      'nationality': nationality,
      'phone': phone,

      // تفاصيل الموقع (لأجير)
      'city': city,
      'district': district,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,

      // تفاصيل أجير
      'specialization': specialization,
      'experience_description': experienceDescription,
      'has_transportation': hasTransportation,

      // تفاصيل المركبة (دينت/سطحة/صهريج)
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'cargo_description': cargoDescription,
    };

    // إضافة البيانات الخاصة بنوع الخدمة
    if (serviceType == 'tanker') {
      data.addAll({
        'plate_letters': plateLetters,
        'plate_numbers': plateNumbers,
        'tanker_size': tankerSize,
        'tanker_services': tankerServices,
      });
    }

    // إعداد الـ FormData
    final FormData formData = FormData.fromMap(data);

    // إضافة الملفات
    await _attachFile(formData, 'personal_image', personalImage);
    await _attachFile(formData, 'id_image', idImage);
    await _attachFile(formData, 'license_image', licenseImage);
    await _attachFile(formData, 'front_image', frontImage);
    await _attachFile(formData, 'back_image', backImage);

    if (extraImages != null) {
      for (int i = 0; i < extraImages!.length; i++) {
        await _attachFile(formData, 'extra_images', extraImages![i], isArray: true);
      }
    }

    return formData;
  }

  // دالة مساعدة لربط الملف بالـ FormData
  Future<void> _attachFile(
      FormData formData, String key, File? file, {bool isArray = false}) async {
    if (file != null && await file.exists()) {
      final fileName = file.path.split('/').last;
      formData.files.add(MapEntry(
        isArray ? '$key[]' : key,
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }
  }
}