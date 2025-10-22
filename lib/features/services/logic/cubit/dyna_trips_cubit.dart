// lib/features/services/logic/cubit/dyna_trips_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../trips/data/repo/dyna_trips_repo.dart';
import '../../data/model/dinat_trip.dart';
import 'dyna_trips_state.dart';

class DynaTripsCubit extends Cubit<DynaTripsState> {
  final DynaTripsRepo _repo;

  List<DynaTrip> _trips = [];
  Pagination _pagination = const Pagination(total: 0, page: 1, pageSize: 10, totalPages: 1);
  bool _loadingMore = false;

  DynaTripsCubit(this._repo) : super(const DynaTripsInitial());

  Future<void> loadInitial({int limit = 10}) async {
    emit(const DynaTripsLoading());
    try {
      final res = await _repo.fetchAvailable(page: 1, limit: limit);
      _trips = res.data;
      _pagination = res.pagination;
      emit(DynaTripsSuccess(trips: _trips, pagination: _pagination));
    } catch (e) {
      emit(DynaTripsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  bool get hasMore => _pagination.page < _pagination.totalPages;

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore || state is! DynaTripsSuccess) return;
    _loadingMore = true;
    emit((state as DynaTripsSuccess).copyWith(loadingMore: true));

    try {
      final nextPage = _pagination.page + 1;
      final res = await _repo.fetchAvailable(page: nextPage, limit: _pagination.pageSize);
      _trips = [..._trips, ...res.data];
      _pagination = res.pagination;
      emit(DynaTripsSuccess(trips: _trips, pagination: _pagination));
    } catch (e) {
      // نحافظ على البيانات الحالية، ويمكنك إظهار Snackbar من الـ UI
      emit((state as DynaTripsSuccess).copyWith(loadingMore: false));
    } finally {
      _loadingMore = false;
    }
  }
}