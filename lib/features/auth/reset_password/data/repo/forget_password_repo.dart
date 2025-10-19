import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../model/forget_password_model.dart';

class ForgetPasswordRepo {
  final ApiService _apiService;

  ForgetPasswordRepo(this._apiService);

  Future<ForgetPasswordResponse> forgetPassword(
      ForgetPasswordRequestBody forgetPasswordRequestBody) async {
    final response = await _apiService.post(
      ApiConstants.forgetPassword,
      forgetPasswordRequestBody.toJson(),
    );
    return ForgetPasswordResponse.fromJson(response);
  }
}
