import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(seconds: 20)
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

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (error) {
      throw AppException.create(error);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}