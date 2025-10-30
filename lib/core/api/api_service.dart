import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

class ApiService {
  final Dio _dio;

  // رسائل ودّية للمستخدم
  static const String _noInternetMsg =
      'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة ثم إعادة المحاولة.';
  static const String _noTokenMsg =
      'يبدو أنك غير مسجل الدخول أو أن الجلسة انتهت. يرجى تسجيل الدخول ثم إعادة المحاولة.';

  ApiService(this._dio) {
    _dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(seconds: 60)
      ..receiveTimeout = const Duration(minutes: 2)
      ..responseType = ResponseType.json
      ..headers = {'Accept': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _getToken();
          // نضيف التوكن إن وجد (لا يفرض المصادقة)
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

  String? _getToken() => CacheHelper.getData(key: 'token') as String?;

  Future<void> _ensureAuth(bool requireAuth) async {
    if (!requireAuth) return;
    final token = _getToken();
    if (token == null || token.isEmpty) {
      throw AppException(_noTokenMsg);
    }
  }

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
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _looksLikeNoInternet(DioException e) async {
    if (_isNetworkTimeoutOrError(e)) return true;
    return await _isOfflineNow();
  }

  Future<Never> _handleDioError(DioException error) async {
    if (await _looksLikeNoInternet(error)) {
      throw AppException(_noInternetMsg);
    }
    final status = error.response?.statusCode ?? 0;
    if (status == 401 || status == 403) {
      throw AppException(_noTokenMsg);
    }
    throw AppException.create(error);
  }

  // ============== Requests ==============

  Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false, // الافتراضي الآن بدون مصادقة
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      await _handleDioError(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response> getResponse(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool relaxStatus = false,
        bool requireAuth = false, // الافتراضي الآن بدون مصادقة
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: relaxStatus
            ? Options(validateStatus: (s) => s != null && s < 500)
            : null,
      );
      return response;
    } on DioException catch (error) {
      if (error.response != null) {
        final status = error.response?.statusCode ?? 0;
        if (status == 401 || status == 403) {
          throw AppException(_noTokenMsg);
        }
        return error.response!;
      }
      await _handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data, {
        bool requireAuth = false, // الافتراضي الآن بدون مصادقة
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      await _handleDioError(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>> postNoData(
      String endpoint, {
        bool requireAuth = false, // الافتراضي الآن بدون مصادقة
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.post(endpoint);
      final d = response.data;
      if (d == null) return {'success': true, 'message': 'تم تنفيذ الطلب بنجاح'};
      if (d is Map<String, dynamic>) return d;
      return {'success': true, 'data': d};
    } on DioException catch (error) {
      await _handleDioError(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>> postForm(
      String endpoint,
      FormData formData, {
        bool requireAuth = false, // الافتراضي الآن بدون مصادقة
      }) async {
    await _ensureAuth(requireAuth);
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
      await _handleDioError(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, {
        dynamic data,
        bool requireAuth = false, // الافتراضي الآن بدون مصادقة
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      await _handleDioError(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteWithBody(
      String endpoint, {
        Map<String, dynamic>? data,
        bool requireAuth = false, // الافتراضي الآن بدون مصادقة
      }) async {
    await _ensureAuth(requireAuth);
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
      await _handleDioError(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}