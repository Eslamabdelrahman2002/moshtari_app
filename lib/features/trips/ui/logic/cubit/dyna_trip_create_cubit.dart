import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/dyna_trip_models.dart';
import '../../../data/repo/dyna_trips_repo.dart';
import 'dyna_trip_create_state.dart';

class DynaTripCreateCubit extends Cubit<DynaTripCreateState> {
  final DynaTripsRepo _repo;
  DynaTripCreateCubit(this._repo) : super(const DynaTripCreateState());

  Future<void> submit(DynaTripCreateRequest req) async {
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      final res = await _repo.addTrip(req);
      if (res.success) {
        emit(state.copyWith(submitting: false, success: true));
      } else {
        emit(state.copyWith(submitting: false, success: false, error: res.message));
      }
    } catch (e) {
      emit(state.copyWith(submitting: false, success: false, error: e.toString()));
    }
  }
}