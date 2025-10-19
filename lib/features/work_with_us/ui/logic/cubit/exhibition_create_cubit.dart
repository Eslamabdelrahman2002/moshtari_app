import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/work_with_us/data/repo/exhibition_create_repo.dart';
import 'exhibition_create_state.dart';

class ExhibitionCreateCubit extends Cubit<ExhibitionCreateState> {
  final ExhibitionCreateRepo _repo;
  ExhibitionCreateCubit(this._repo) : super(const ExhibitionCreateState());

  Future<void> submit({
    required String name,
    required String email,
    required String activityType,
    required String phoneNumber,
    required String address,
    required int cityId,
    required int regionId,
    required File image,
  }) async {
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      await _repo.create(
        name: name,
        email: email,
        activityType: activityType,
        phoneNumber: phoneNumber,
        address: address,
        cityId: cityId,
        regionId: regionId,
        image: image,
      );
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, success: false, error: e.toString()));
    }
  }
}