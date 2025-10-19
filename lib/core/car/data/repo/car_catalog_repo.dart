// lib/features/cars/data/repo/car_catalog_repo.dart
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart' as api;


import '../model/car_model.dart';
import '../model/car_type.dart';


class CarCatalogRepo {
  final api.ApiService _api;

  CarCatalogRepo(this._api);

  Future<List<CarType>> fetchCarTypes() async {
    final res = await _api.get(ApiConstants.carTypes);

    // 🟢 الإصلاح: res هو الـ Map مباشرة، لذا الوصول إلى ['data'] يكون مباشرة من res
    final list = (res['data'] as List?) ?? [];

    return list.map((e) => CarType.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<CarModel>> fetchModels(int typeId) async {
    final res = await _api.get(ApiConstants.carTypeModels(typeId));

    // 🟢 الإصلاح: res هو الـ Map مباشرة، لذا الوصول إلى ['data'] يكون مباشرة من res
    final list = (res['data'] as List?) ?? [];

    return list.map((e) => CarModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}