import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import '../model/other_ad_request.dart';

class OtherAdsCreateRepo {
  final Dio dio;
  OtherAdsCreateRepo(this.dio);

  Future<Response> createOtherAd(OtherAdRequest req) async {
    final data = await req.toFormData();

    // Debug قبل الإرسال
    if (data is FormData) {
      // ignore: avoid_print
      print('--- OtherAd FormData (outgoing) ---');
      for (final f in data.fields) {
        print('${f.key} = ${f.value}');
      }
      for (final f in data.files) {
        print('${f.key} -> ${f.value.filename}');
      }
    }

    final res = await dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.otherAds}',
      data: data,
      options: Options(
        // دع Dio يعين boundary تلقائيًا (لا contentType يدويًا)
        validateStatus: (code) => code != null && code < 600,
        headers: {
          'Accept-Language': 'ar',
          'lang': 'ar',
          // إذا لم يكن لديك Interceptor للتوكن أضِفه هنا:
          // 'Authorization': 'Bearer $token',
        },
      ),
    );

    // Debug بعد الاستجابة
    // ignore: avoid_print
    print('Create OtherAd -> status: ${res.statusCode}, data: ${res.data}');

    if (res.statusCode == 200 || res.statusCode == 201) {
      return res;
    }

    final msg = _extractServerError(res.data) ??
        'فشل نشر الإعلان (HTTP ${res.statusCode})';
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      error: msg,
    );
  }

  String? _extractServerError(dynamic data) {
    try {
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
      }
      if (data != null) return data.toString();
      return null;
    } catch (_) {
      return null;
    }
  }
}