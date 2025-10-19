import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../models/login_model.dart';

class LoginRepo {
  final ApiService _apiService;

  LoginRepo(this._apiService);

  Future<LoginResponse> login(LoginRequestBody loginRequestBody) async {
    final response = await _apiService.post(
      ApiConstants.login,
      loginRequestBody.toJson(),
    );
    return LoginResponse.fromJson(response);
  }
}
