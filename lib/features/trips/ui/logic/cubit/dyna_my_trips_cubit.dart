import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';

import '../../../data/model/dyna_trips_list_models.dart';
import '../../../data/repo/dyna_trips_repo.dart';
import 'dyna_trips_list_state.dart';

class DynaMyTripsCubit extends Cubit<DynaTripsListState> {
  final DynaTripsRepo _repo;
  DynaMyTripsCubit(this._repo) : super(const DynaTripsListState());

  Future<void> initLoad({int pageSize = 10}) async {
    emit(state.copyWith(loading: true, error: null, items: [], page: 1, pageSize: pageSize));
    try {
      final res = await _repo.fetchMyTrips(
        page: 1,
        pageSize: pageSize,
        fromCityId: state.fromCity?.id,
        toCityId: state.toCity?.id,
      );
      emit(state.copyWith(
        loading: false,
        items: res.data,
        page: res.pagination.page,
        totalPages: res.pagination.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
  Future<void> deleteTrip(int id) async {
    emit(state.copyWith(actingId: id));
    try {
      await _repo.deleteTrip(id);
      final filtered = state.items.where((t) => t.id != id).toList();
      emit(state.copyWith(items: filtered, actingId: null));
    } catch (e) {
      emit(state.copyWith(actingId: null, error: e.toString()));
    }
  }

  Future<void> updateTrip(int id, Map<String, dynamic> data) async {
    emit(state.copyWith(actingId: id));
    try {
      await _repo.updateTrip(id, data);
      await initLoad(pageSize: state.pageSize);
    } catch (e) {
      emit(state.copyWith(actingId: null, error: e.toString()));
    }
  }
  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.loading) return;
    final next = state.page + 1;
    emit(state.copyWith(loadingMore: true));
    try {
      final res = await _repo.fetchMyTrips(
        page: next,
        pageSize: state.pageSize,
        fromCityId: state.fromCity?.id,
        toCityId: state.toCity?.id,
      );
      final merged = List<DynaTripItem>.from(state.items)..addAll(res.data);
      emit(state.copyWith(
        loadingMore: false,
        items: merged,
        page: res.pagination.page,
        totalPages: res.pagination.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, error: e.toString()));
    }
  }

  void setFromCity(City? city) => emit(state.copyWith(fromCity: city));
  void setToCity(City? city) => emit(state.copyWith(toCity: city));

  Future<void> applyFilters() async => initLoad(pageSize: state.pageSize);

  void clearFilters() {
    emit(state.copyWith(fromCity: null, toCity: null));
    initLoad(pageSize: state.pageSize);
  }
}