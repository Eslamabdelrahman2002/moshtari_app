import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/commission_models.dart';
class CommissionRepo {
  final ApiService _api;
  CommissionRepo(this._api);

  Future<List<CommissionItem>> fetchAll() async {
    final res = await _api.get(ApiConstants.commission);
    final parsed = CommissionResponse.fromJson(res as Map<String, dynamic>);
    return parsed.data;
  }
}