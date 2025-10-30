import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/features/auth/login/logic/cubit/login_state.dart';

import '../../../../../core/notification/fcm_service.dart';
import '../../../../../core/utils/helpers/cache_helper.dart';
import '../../data/models/login_model.dart';
import '../../data/repo/login_repo.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;
  LoginCubit(this._loginRepo) : super(LoginInitial());

  Future<void> login(String phoneNumber) async {
    emit(LoginLoading());
    try {
      final loginRequestBody = LoginRequestBody(phoneNumber: phoneNumber);

      // هات الـ FCM token
      final fcm = await FcmService.currentToken();

      // ابعته للريبو
      final response = await _loginRepo.login(
        loginRequestBody,
        fcmToken: fcm, // <-- مهم
      );

      final token = response.data?.token;
      if (token != null && token.isNotEmpty) {
        await CacheHelper.saveData(key: 'token', value: token);
      }
      emit(LoginSuccess(response));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(LoginError(msg));
    }
  }
}