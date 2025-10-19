import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/reset_passwod_model.dart';

class ResetPasswordRepo {
  final ApiService _apiService;

  ResetPasswordRepo(this._apiService);

  Future<ResetPasswordResponse> resetPassword(
      ResetPasswordRequestBody resetPasswordRequestBody) async {
    final response = await _apiService.post(
      ApiConstants.resetPassword,
      resetPasswordRequestBody.toJson(),
    );
    return ResetPasswordResponse.fromJson(response);
  }
}
