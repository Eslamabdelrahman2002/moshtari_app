import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/features/auth/login/logic/cubit/login_state.dart';

import '../../../../../core/utils/helpers/cache_helper.dart';
import '../../data/models/login_model.dart';
import '../../data/repo/login_repo.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(LoginInitial());

  Future<void> login(String phoneNumber) async {
    emit(LoginLoading());
    try {
      final fakeResponse = LoginResponse(message: 'تم الانتقال إلى شاشة التحقق');
      emit(LoginSuccess(fakeResponse));
      final loginRequestBody = LoginRequestBody(phoneNumber: phoneNumber);
      final response = await _loginRepo.login(loginRequestBody);

      if (response.data?.token != null) {
        await CacheHelper.saveData(key: 'token', value: response.data!.token!);
      }

      emit(LoginSuccess(response));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}