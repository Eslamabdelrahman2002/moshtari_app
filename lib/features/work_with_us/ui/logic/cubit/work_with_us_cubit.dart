// features/work_with_us/logic/cubit/work_with_us_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/work_with_us_repo.dart';
import 'work_with_us_state.dart';

class WorkWithUsCubit extends Cubit<WorkWithUsState> {
  final WorkWithUsRepo _repo;
  WorkWithUsCubit(this._repo) : super(const WorkWithUsState());

  Future<void> submit({
    required String fullName,
    required String phone,
    required String email,
    required int regionId,
    required int cityId,
    required String employmentStatus,
    required File idDocument,
    required String nationalId,
    required String birthDateIso, // yyyy-MM-dd
  }) async {
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      await _repo.applyPromoter(
        fullName: fullName,
        phone: phone,
        email: email,
        regionId: regionId,
        cityId: cityId,
        employmentStatus: employmentStatus,
        idDocument: idDocument,
        nationalId: nationalId,
        birthDate: birthDateIso,
      );
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }
}