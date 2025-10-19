import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/enums/otp_case.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
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
    // ✨ DEBUG PRINT 1 ✨
    print('--- CUBIT: verifyOtp method started ---');
    print('--- CUBIT: Received otpCase: $otpCase');

    emit(OtpVerificationLoading());
    try {
      final requestBody = VerifyOtpRequestBody(phoneNumber: phoneNumber, otp: otp);

      // ✨ DEBUG PRINT 2 ✨
      print('--- CUBIT: Created request body. Now checking otpCase...');

      OtpResponse response;
      if (otpCase == OtpCase.resetPassword) {
        // ✨ DEBUG PRINT 3a ✨
        print('--- CUBIT: otpCase is resetPassword. Calling repo...');
        response = await _otpRepo.verifyResetPasswordOtp(requestBody);
      } else {
        // ✨ DEBUG PRINT 3b ✨
        print('--- CUBIT: otpCase is NOT resetPassword. Calling repo for registration...');
        response = await _otpRepo.verifyRegistrationOtp(requestBody);
      }

      // ✨ DEBUG PRINT 4 ✨
      print('--- CUBIT: Got response from repo. Token: ${response.token}');

      if (otpCase != OtpCase.resetPassword && response.token != null) {
        await CacheHelper.saveData(key: 'token', value: response.token!);
        emit(OtpVerificationSuccess(response.message ?? 'Verification Success!', otp));
      } else if (otpCase == OtpCase.resetPassword) {
        emit(OtpVerificationSuccess(response.message ?? 'Verification Success!', otp));
      } else {
        emit(OtpVerificationError('Verification successful, but no token was received.'));
      }
      // ✨ DEBUG PRINT 5 ✨
      print('--- CUBIT: Emitted success state ---');
    } catch (e) {
      // ✨ DEBUG PRINT 6 ✨
      print('--- CUBIT: CAUGHT AN ERROR! Error: ${e.toString()}');
      emit(OtpVerificationError(e.toString()));
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    emit(ResendOtpLoading());
    try {
      final requestBody = ResendOtpRequestBody(phoneNumber: phoneNumber);
      final response = await _otpRepo.resendOtp(requestBody);
      emit(ResendOtpSuccess(response.message ?? 'OTP Resent Successfully!'));
    } catch (e) {
      emit(ResendOtpError(e.toString()));
    }
  }
}