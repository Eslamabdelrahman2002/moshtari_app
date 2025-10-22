import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options
      ..baseUrl = ApiConstants.baseUrl
    // ✅ 1. تم زيادة connectTimeout إلى 60 ثانية لحل مشكلة الـ Timeout
      ..connectTimeout = const Duration(seconds: 60)
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

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
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
      if (error.response != null) return error.response!;
      throw AppException.create(error);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // ✅ 2. دالة جديدة لتنفيذ POST بدون إرسال Body (للخروج/الإجراءات البسيطة)
  Future<Map<String, dynamic>> postNoData(String endpoint) async {
    try {
      // إرسال طلب POST بدون تمرير أي بيانات في الـ data
      final response = await _dio.post(endpoint);
      // التعامل مع حالة إذا كان الخادم لا يرجع بيانات
      final d = response.data;
      if (d == null) return {'success': true, 'message': 'تم تسجيل الخروج بنجاح'};
      if (d is Map<String, dynamic>) return d;
      return {'success': true, 'data': d};
    } on DioException catch (error) {
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
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}