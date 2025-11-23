import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/dyna_trip_models.dart';
import '../../../data/repo/dyna_trips_repo.dart';
import 'dyna_trip_create_state.dart';

class DynaTripCreateCubit extends Cubit<DynaTripCreateState> {
  final DynaTripsRepo _repo;
  DynaTripCreateCubit(this._repo) : super(const DynaTripCreateState());

  // إنشاء رحلة
  Future<void> submit(DynaTripCreateRequest req) async {
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      await _repo.addTrip(req);
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, success: false, error: e.toString()));
    }
  }

  // تعديل رحلة
  Future<void> updateTrip(int id, Map<String, dynamic> data) async {
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      await _repo.updateTrip(id, data);
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, success: false, error: e.toString()));
    }
  }
}