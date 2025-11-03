import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import '../model/other_ad_request.dart';

class OtherAdsCreateRepo {
  final ApiService _api = getIt<ApiService>();

  Future<Response> createOtherAd(OtherAdRequest req) async {
    final formData = await req.toFormData();

    // Debug - طباعة البيانات قبل الإرسال
    print('--- OtherAd FormData (outgoing) ---');
    for (var f in formData.fields) {
      print('${f.key} = ${f.value}');
    }
    for (var f in formData.files) {
      print('${f.key} -> ${f.value.filename}');
    }

    // 🔹 نستخدم ApiService.postForm مع requireAuth: true عشان يفتح البوتمشيت عند غياب التوكن
    final data = await _api.postForm(
      ApiConstants.otherAds,
      formData,
      requireAuth: true, // ✅ هنا المفتاح
    );

    // Debug بعد الاستجابة
    print('Create OtherAd -> data: $data');

    // بنلفها في Response عشان الكولر يتعامل مع نفس الشكل القديم لو لازم
    return Response(
      requestOptions: RequestOptions(path: ApiConstants.otherAds),
      data: data,
      statusCode: 200,
    );
  }
}