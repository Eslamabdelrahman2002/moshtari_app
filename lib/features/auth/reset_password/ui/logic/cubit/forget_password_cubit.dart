import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/forget_password_model.dart';
import '../../../data/repo/forget_password_repo.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepo _forgetPasswordRepo;

  ForgetPasswordCubit(this._forgetPasswordRepo) : super(ForgetPasswordInitial());

  Future<void> forgetPassword(String phoneNumber) async {
    emit(ForgetPasswordLoading());
    try {
      final requestBody = ForgetPasswordRequestBody(phoneNumber: phoneNumber);
      final response = await _forgetPasswordRepo.forgetPassword(requestBody);
      emit(ForgetPasswordSuccess(response.message ?? 'OTP sent successfully!'));
    } catch (e) {
      emit(ForgetPasswordError(e.toString()));
    }
  }
}
