import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

import '../auth/auth_coordinator.dart';

class ApiService {
  final Dio _dio;

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
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (object) => print(object.toString()),
      ),
    );
  }

  // ================= Helpers =================

  String? _getToken() => CacheHelper.getData(key: 'token') as String?;

  bool _isNetworkTimeoutOrError(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException;

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

  /// ✅ تأكيد وجود التوكن، وإظهار الـBottomSheet لو مش موجود
  Future<void> _ensureAuth(bool requireAuth) async {
    if (!requireAuth) return;

    final token = _getToken();
    if (token != null && token.isNotEmpty) return;

    print('🟢 ApiService: No token, opening auth bottom sheet...');
    final auth = getIt<AuthCoordinator>();
    final newToken = await auth.ensureTokenInteractive();

    if (newToken == null || newToken.isEmpty) {
      throw AppException(_noTokenMsg);
    }
  }

  /// ✅ إعادة المحاولة بعد تحديث التوكن
  Future<Response> _retry(RequestOptions req) async {
    final freshToken = _getToken();
    final headers = Map<String, dynamic>.from(req.headers);
    if (freshToken != null && freshToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $freshToken';
    }

    final opts = Options(
      method: req.method,
      headers: headers,
      responseType: req.responseType,
      contentType: req.contentType,
    );

    return _dio.request(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      options: opts,
      cancelToken: req.cancelToken,
    );
  }

  // ================= Requests =================

  Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false,
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response =
      await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      final status = error.response?.statusCode ?? 0;
      if (status == 401 && requireAuth) {
        final auth = getIt<AuthCoordinator>();
        final t = await auth.ensureTokenInteractive();
        if (t != null && t.isNotEmpty) {
          final retried = await _retry(error.requestOptions);
          return retried.data;
        }
      }
      await _handleDioError(error);
    }
  }

  Future<Response> getResponse(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false,
        bool relaxStatus = false,
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
      final status = error.response?.statusCode ?? 0;
      if (status == 401 && requireAuth) {
        final auth = getIt<AuthCoordinator>();
        final t = await auth.ensureTokenInteractive();
        if (t != null && t.isNotEmpty) {
          return await _retry(error.requestOptions);
        }
      }
      await _handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data, {
        bool requireAuth = false,
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      final status = error.response?.statusCode ?? 0;
      if (status == 401 && requireAuth) {
        final auth = getIt<AuthCoordinator>();
        final t = await auth.ensureTokenInteractive();
        if (t != null && t.isNotEmpty) {
          final retried = await _retry(error.requestOptions);
          return retried.data;
        }
      }
      await _handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> postNoData(
      String endpoint, {
        bool requireAuth = false,
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.post(endpoint);
      final d = response.data;
      if (d == null) return {'success': true, 'message': 'تم تنفيذ الطلب بنجاح'};
      if (d is Map<String, dynamic>) return d;
      return {'success': true, 'data': d};
    } on DioException catch (error) {
      final status = error.response?.statusCode ?? 0;
      if (status == 401 && requireAuth) {
        final auth = getIt<AuthCoordinator>();
        final t = await auth.ensureTokenInteractive();
        if (t != null && t.isNotEmpty) {
          final retried = await _retry(error.requestOptions);
          final d = retried.data;
          if (d == null) return {'success': true, 'message': 'تم تنفيذ الطلب بنجاح'};
          if (d is Map<String, dynamic>) return d;
          return {'success': true, 'data': d};
        }
      }
      await _handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> postForm(
      String endpoint,
      FormData formData, {
        bool requireAuth = false,
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
      final status = error.response?.statusCode ?? 0;
      if (status == 401 && requireAuth) {
        final auth = getIt<AuthCoordinator>();
        final t = await auth.ensureTokenInteractive();
        if (t != null && t.isNotEmpty) {
          final retried = await _retry(error.requestOptions);
          return retried.data;
        }
      }
      await _handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, {
        dynamic data,
        bool requireAuth = false,
      }) async {
    await _ensureAuth(requireAuth);
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      final status = error.response?.statusCode ?? 0;
      if (status == 401 && requireAuth) {
        final auth = getIt<AuthCoordinator>();
        final t = await auth.ensureTokenInteractive();
        if (t != null && t.isNotEmpty) {
          final retried = await _retry(error.requestOptions);
          return retried.data;
        }
      }
      await _handleDioError(error);
    }
  }

  Future<Map<String, dynamic>> deleteWithBody(
      String endpoint, {
        Map<String, dynamic>? data,
        bool requireAuth = false,
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
      final status = error.response?.statusCode ?? 0;
      if (status == 401 && requireAuth) {
        final auth = getIt<AuthCoordinator>();
        final t = await auth.ensureTokenInteractive();
        if (t != null && t.isNotEmpty) {
          final retried = await _retry(error.requestOptions);
          return retried.data;
        }
      }
      await _handleDioError(error);
    }
  }
}