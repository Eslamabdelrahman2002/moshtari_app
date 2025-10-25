import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

class ApiService {
  final Dio _dio;

  // رسالة ودّية لعدم وجود الإنترنت
  static const String _noInternetMsg = 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة ثم إعادة المحاولة.';

  ApiService(this._dio) {
    _dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(seconds: 60) // مهلة أطول
      ..receiveTimeout = const Duration(minutes: 2)
      ..responseType = ResponseType.json
      ..headers = {'Accept': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = CacheHelper.getData(key: 'token') as String?;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (options.data is FormData) {
            options.headers['Content-Type'] = 'multipart/form-data';
          }
          handler.next(options);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) => print(object.toString()),
      ),
    );
  }

  // ============== Helpers ==============

  bool _isNetworkTimeoutOrError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
  }

  Future<bool> _isOfflineNow() async {
    try {
      final res = await Connectivity().checkConnectivity();
      return res == ConnectivityResult.none;
    } on MissingPluginException {
      // أحيانًا بعد Hot Restart البلجن لا يكون جاهزًا؛ لا نكسر الواجهة
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _looksLikeNoInternet(DioException e) async {
    if (_isNetworkTimeoutOrError(e)) return true;
    // تأكيد إضافي عبر Connectivity (اختياري)
    return await _isOfflineNow();
  }

  // ============== Requests ==============

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      if (await _looksLikeNoInternet(error)) {
        throw AppException(_noInternetMsg);
      }
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response> getResponse(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool relaxStatus = false,
      }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: relaxStatus ? Options(validateStatus: (s) => s != null && s < 500) : null,
      );
      return response;
    } on DioException catch (error) {
      // في بعض الحالات نعيد الـ response بدل الخطأ (نفس سلوكك السابق)
      if (error.response != null) return error.response!;
      if (await _looksLikeNoInternet(error)) {
        throw AppException(_noInternetMsg);
      }
      throw AppException.create(error);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      if (await _looksLikeNoInternet(error)) {
        throw AppException(_noInternetMsg);
      }
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // POST بدون Body (مثل الخروج)
  Future<Map<String, dynamic>> postNoData(String endpoint) async {
    try {
      final response = await _dio.post(endpoint);
      final d = response.data;
      if (d == null) return {'success': true, 'message': 'تم تنفيذ الطلب بنجاح'};
      if (d is Map<String, dynamic>) return d;
      return {'success': true, 'data': d};
    } on DioException catch (error) {
      if (await _looksLikeNoInternet(error)) {
        throw AppException(_noInternetMsg);
      }
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>> postForm(String endpoint, FormData formData) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.data;
    } on DioException catch (error) {
      if (await _looksLikeNoInternet(error)) {
        throw AppException(_noInternetMsg);
      }
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      if (await _looksLikeNoInternet(error)) {
        throw AppException(_noInternetMsg);
      }
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteWithBody(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final d = response.data;
      if (d is Map<String, dynamic>) return d;
      return {'success': true, 'data': d};
    } on DioException catch (error) {
      if (await _looksLikeNoInternet(error)) {
        throw AppException(_noInternetMsg);
      }
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}