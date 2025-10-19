import 'dart:convert';
import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;

  static AppException create(DioException e) {
    final status = e.response?.statusCode;
    final ct = e.response?.headers.value('content-type') ?? '';
    final data = e.response?.data;

    String msg = e.message ?? 'خطأ غير معروف';

    if (status == 404) {
      return AppException('المورد غير موجود', statusCode: status);
    }

    if (data is Map && data['message'] != null) {
      msg = data['message'].toString();
    } else if (data is String) {
      if (ct.contains('text/html')) {
        msg = 'استجابة HTML من الخادم';
      } else {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'].toString();
          } else {
            msg = data;
          }
        } catch (_) {
          msg = data;
        }
      }
    }

    return AppException(msg, statusCode: status);
    // ملاحظة: لا تفهرس data['message'] مباشرة لو data String
  }
}