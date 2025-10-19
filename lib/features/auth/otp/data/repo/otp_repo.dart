import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../models/otp_model.dart';

class OtpRepo {
  final ApiService _apiService;

  OtpRepo(this._apiService);

  Future<OtpResponse> verifyRegistrationOtp(VerifyOtpRequestBody body) async {
    final response = await _apiService.post(
      ApiConstants.verifyRegistration,
      body.toJson(),
    );
    return OtpResponse.fromJson(response);
  }

  // ✨ ADDED for password reset flow
  Future<OtpResponse> verifyResetPasswordOtp(VerifyOtpRequestBody body) async {
    final response = await _apiService.post(
      ApiConstants.verifyResetPassword,
      body.toJson(),
    );
    return OtpResponse.fromJson(response);
  }

  Future<OtpResponse> resendOtp(ResendOtpRequestBody resendOtpRequestBody) async {
    final response = await _apiService.post(
      ApiConstants.verifyRegistration,
      resendOtpRequestBody.toJson(),
    );
    return OtpResponse.fromJson(response);
  }
}