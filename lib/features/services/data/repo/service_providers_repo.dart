import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/api_constants.dart';
import '../model/service_provider_model.dart';

class ServiceProvidersRepo {
  final ApiService _api;
  ServiceProvidersRepo(this._api);

  Future<List<ServiceProviderModel>> fetchByLabour({
    required int labourId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final resp = await _api.get(
        ApiConstants.serviceProviders,
        queryParameters: {'labour_id': labourId, 'page': page, 'pageSize': pageSize},
      );
      if (resp is Map && resp['data'] is List) {
        return (resp['data'] as List)
            .map((e) => ServiceProviderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching service providers: $e');
    }
  }
}