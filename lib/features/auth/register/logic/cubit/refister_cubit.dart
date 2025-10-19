import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/auth/register/logic/cubit/register_state.dart';

import '../../data/models/register_model.dart';
import '../../data/repo/register_repo.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo _registerRepo;

  RegisterCubit(this._registerRepo) : super(RegisterInitial());

  Future<void> register(RegisterRequestBody registerRequestBody) async {
    emit(RegisterLoading());
    try {
      final response = await _registerRepo.register(registerRequestBody);
      emit(RegisterSuccess(response.message ?? 'Registration successful!'));
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }
}
