import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/exhibition_create_models.dart';
import '../../../data/repo/exhibition_create_repo.dart';
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
    // تم حذف: int? promoterId,
  }) async {
    emit(state.copyWith(
        submitting: true, success: false, clearError: true, clearId: true));

    try {
      final req = ExhibitionCreateRequest(
        name: name,
        email: email,
        activityType: activityType,
        phoneNumber: phoneNumber,
        address: address,
        cityId: cityId,
        regionId: regionId,
        image: image,
        // تم حذف: promoterId: promoterId,
      );

      final res = await _repo.createExhibition(req);

      if (!res.success) {
        throw Exception(
            res.message.isNotEmpty ? res.message : 'تعذر إنشاء الحساب');
      }

      emit(state.copyWith(
        submitting: false,
        success: true,
        createdId: res.id,
      ));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(submitting: false, success: false, error: msg));
    }
  }

  void reset() {
    emit(const ExhibitionCreateState());
  }
}