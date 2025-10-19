import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import '../model/car_details_model.dart';

class CarDetailsRepo {
  final ApiService api;
  CarDetailsRepo(this.api);

  Future<CarDetailsModel> fetchCarDetails(int id) async {
    // نحصل على Response ونسمح بغير 2xx
    Response res = await api.getResponse(
      ApiConstants.carAdDetails(id), // ✅ car-ads/$id
      relaxStatus: true,
    );

    // 404؟ جرّب شكل بديل (?id=) مرة واحدة كفولبـاك
    if (res.statusCode == 404) {
      res = await api.getResponse(
        ApiConstants.carAdDetailsByQuery(id), // car-ads?id=23
        relaxStatus: true,
      );
    }

    final ct = res.headers.value('content-type') ?? '';

    if (res.statusCode == 200) {
      final body = _asJsonMap(res.data, ct);
      return CarDetailsModel.fromJson(body);
    }

    if (res.statusCode == 404) {
      throw AppException('الإعلان غير موجود');
    }

    final msg = _extractMessage(res.data, ct);
    throw AppException('HTTP ${res.statusCode}: $msg');
  }

  Map<String, dynamic> _asJsonMap(dynamic data, String contentType) {
    if (data is Map<String, dynamic>) return data;
    if (data is String && contentType.contains('application/json')) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    throw const FormatException('Unexpected response (not JSON).');
  }

  String _extractMessage(dynamic data, String contentType) {
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (data is String) {
      if (contentType.contains('text/html')) return 'استجابة HTML من الخادم';
      try {
        final d = jsonDecode(data);
        if (d is Map && d['message'] != null) return d['message'].toString();
      } catch (_) {}
      return data;
    }
    return 'حدث خطأ غير متوقع';
  }
}