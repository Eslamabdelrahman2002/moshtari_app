import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../models/otp_model.dart';

class OtpRepo {
  final ApiService _apiService;
  OtpRepo(this._apiService);

  Future<OtpResponse> verifyRegistrationOtp(
      VerifyOtpRequestBody body, {
        String? fcmToken, // <-- جديد
      }) async {
    final map = {
      ...body.toJson(),
      if ((fcmToken ?? '').isNotEmpty) 'fcm_token': fcmToken,
    };
    final response = await _apiService.post(ApiConstants.verifyRegistration, map);
    return OtpResponse.fromJson(response);
  }

  Future<OtpResponse> verifyResetPasswordOtp(VerifyOtpRequestBody body) async {
    final response = await _apiService.post(
      ApiConstants.verifyResetPassword,
      body.toJson(),
    );
    return OtpResponse.fromJson(response);
  }

  Future<OtpResponse> resendOtp(ResendOtpRequestBody body) async {
    final response = await _apiService.post(
      ApiConstants.resendOtp, // <-- هنعرفه في ApiConstants تحت
      body.toJson(),
    );
    return OtpResponse.fromJson(response);
  }
}