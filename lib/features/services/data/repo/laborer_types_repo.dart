import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/laborer_type_model.dart';

class LaborerTypesRepo {
  final ApiService _api;
  LaborerTypesRepo(this._api);

  Future<List<LaborerType>> fetch() async {
    try {
      final resp = await _api.get(ApiConstants.laborerTypes);
      if (resp is Map && resp['data'] is List) {
        return (resp['data'] as List)
            .map((e) => LaborerType.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching laborer types: $e');
    }
  }
}