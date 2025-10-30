import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/enums/otp_case.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
import '../../../../core/notification/fcm_service.dart';
import '../data/models/otp_model.dart';
import '../data/repo/otp_repo.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepo _otpRepo;
  OtpCubit(this._otpRepo) : super(OtpInitial());

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
    required OtpCase otpCase,
  }) async {
    emit(OtpVerificationLoading());
    try {
      final body = VerifyOtpRequestBody(phoneNumber: phoneNumber, otp: otp);
      OtpResponse res;
      if (otpCase == OtpCase.resetPassword) {
        res = await _otpRepo.verifyResetPasswordOtp(body);
      } else {
        final fcm = await FcmService.currentToken();
        res = await _otpRepo.verifyRegistrationOtp(body, fcmToken: fcm);
      }
      if (otpCase != OtpCase.resetPassword && res.token != null) {
        await CacheHelper.saveData(key: 'token', value: res.token!);
      }
      emit(OtpVerificationSuccess(res.message ?? 'Verification Success!', otp));
    } catch (e) {
      emit(OtpVerificationError(e.toString()));
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    emit(ResendOtpLoading());
    try {
      final res = await _otpRepo.resendOtp(ResendOtpRequestBody(phoneNumber: phoneNumber));
      emit(ResendOtpSuccess(res.message ?? 'OTP Resent Successfully!'));
    } catch (e) {
      emit(ResendOtpError(e.toString()));
    }
  }
}