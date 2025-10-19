import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/auth/reset_password/ui/logic/cubit/reset_password_state.dart';

import '../../../../../../core/api/app_exception.dart';
import '../../../data/model/reset_passwod_model.dart';
import '../../../data/repo/reset_password_repo.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepo _resetPasswordRepo;

  ResetPasswordCubit(this._resetPasswordRepo) : super(ResetPasswordInitial());

  // This method is now updated to accept named parameters from the UI
  void resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    emit(ResetPasswordLoading());
    try {
      // The RequestBody is now created inside the Cubit
      final requestBody = ResetPasswordRequestBody(
        phoneNumber: phoneNumber,
        otp: otp,
        password: newPassword,
        passwordConfirmation: newPassword, // Assuming confirmation is the same
      );
      final response = await _resetPasswordRepo.resetPassword(requestBody);
      emit(ResetPasswordSuccess(response.message ?? 'Password reset successful!'));
    } on AppException catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }
}


