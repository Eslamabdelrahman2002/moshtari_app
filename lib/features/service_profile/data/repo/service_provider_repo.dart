import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../model/service_provider_models.dart';
import '../model/service_request_models.dart';


class ServiceProviderRepo {
  final ApiService _api;
  ServiceProviderRepo(this._api);

  Future<ServiceProviderModel> fetchProvider(int id) async {
    final res = await _api.get(ApiConstants.serviceProviderProfile(id));
    return ServiceProviderModel.fromJson((res as Map<String, dynamic>)['data'] ?? {});
  }

  Future<List<ServiceRequest>> fetchServiceRequests() async {
    final res = await _api.get(ApiConstants.serviceProviderRequests);
    final parsed = ServiceRequestsResponse.fromJson(res as Map<String, dynamic>);
    return parsed.data;
  }

  Future<void> updateRequestStatus(int requestId, String newStatus) async {
    await _api.post(ApiConstants.serviceProviderUpdateRequestStatus(requestId), {
      'new_status': newStatus,
    });
  }
}