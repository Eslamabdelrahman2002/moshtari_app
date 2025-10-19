// lib/features/services/data/repo/service_registration_repo.dart

import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../model/service_registration_model.dart';

class ServiceRegistrationRepo {
  final ApiService _apiService;

  ServiceRegistrationRepo(this._apiService);

  Future<void> registerService(ServiceProviderRegistrationModel model) async {
    // 1. تحويل النموذج إلى FormData (يشمل الملفات)
    final formData = await model.toFormData();

    // 2. إرسال الطلب
    final response = await _apiService.postForm(
      ApiConstants.registerServiceProvider,
      formData,
    );

    // يمكنك إضافة منطق تحليل الاستجابة هنا إذا كانت تتضمن بيانات هامة
    if (response['message'] != null && response['message'] == 'Registration successful') {
      // تم بنجاح
      return;
    }

    // إذا كان هناك خطأ في الاستجابة
    throw Exception(response['message'] ?? 'فشل تسجيل مقدم الخدمة');
  }
}