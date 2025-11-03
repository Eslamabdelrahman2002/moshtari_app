import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart' as api;
import '../model/service_request_payload.dart';

class ServiceRequestRepo {
  final api.ApiService _api;
  ServiceRequestRepo(this._api);

  Future<Map<String, dynamic>> create(CreateServiceRequest req) async {
    // جرّب create أولاً ثم بديل /service-requests عند الحاجة
    try {
      return await _api.post(ApiConstants.serviceRequestsCreate, req.toJson(),requireAuth: true);
    } catch (_) {
      return await _api.post(ApiConstants.serviceRequests, req.toJson(),requireAuth: true);
    }
  }
}