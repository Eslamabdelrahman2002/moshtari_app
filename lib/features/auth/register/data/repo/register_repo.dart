import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../models/register_model.dart';

class RegisterRepo {
  final ApiService _apiService;

  RegisterRepo(this._apiService);

  Future<RegisterResponse> register(
      RegisterRequestBody registerRequestBody) async {
    final response = await _apiService.post(
      ApiConstants.register,
      registerRequestBody.toJson(),
    );
    return RegisterResponse.fromJson(response);
  }
}
