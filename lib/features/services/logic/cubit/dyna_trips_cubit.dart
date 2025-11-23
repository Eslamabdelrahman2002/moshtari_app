import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../trips/data/repo/dyna_trips_repo.dart';
import '../../data/model/dinat_trip.dart';
import '../../data/model/dyna_trips_filter.dart';
import 'dyna_trips_state.dart';

class DynaTripsCubit extends Cubit<DynaTripsState> {
  final DynaTripsRepo _repo;

  List<DynaTrip> _trips = [];
  Pagination _pagination = const Pagination(total: 0, page: 1, pageSize: 10, totalPages: 1);
  bool _loadingMore = false;

  DynaTripsFilter _filter = const DynaTripsFilter();

  DynaTripsCubit(this._repo) : super(const DynaTripsInitial());

  DynaTripsFilter get currentFilter => _filter;
  bool get hasMore => _pagination.page < _pagination.totalPages;

  Future<void> loadInitial({int limit = 10}) async {
    emit(const DynaTripsLoading());
    try {
      final res = await _repo.fetchAvailable(
        page: 1,
        limit: limit,
        // تمرير الفلاتر كـ Query
        fromCityId: _filter.fromCityId,
        toCityId: _filter.toCityId,
        dynaCapacity: _filter.dynaCapacity,
        regionId: _filter.regionId,
        date: _filter.date, // DateTime? - تأكد أن الريبو يرسل YYYY-MM-DD
      );
      _trips = res.data;
      _pagination = res.pagination;
      emit(DynaTripsSuccess(trips: _trips, pagination: _pagination));
    } catch (e) {
      emit(DynaTripsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> applyFilter(DynaTripsFilter filter) async {
    _filter = filter;
    await loadInitial(limit: _pagination.pageSize);
  }

  Future<void> resetFilter() async {
    _filter = const DynaTripsFilter();
    await loadInitial(limit: _pagination.pageSize);
  }

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore || state is! DynaTripsSuccess) return;
    _loadingMore = true;
    emit((state as DynaTripsSuccess).copyWith(loadingMore: true));

    try {
      final nextPage = _pagination.page + 1;
      final res = await _repo.fetchAvailable(
        page: nextPage,
        limit: _pagination.pageSize,
        fromCityId: _filter.fromCityId,
        toCityId: _filter.toCityId,
        dynaCapacity: _filter.dynaCapacity,
        regionId: _filter.regionId,
        date: _filter.date,
      );
      _trips = [..._trips, ...res.data];
      _pagination = res.pagination;
      emit(DynaTripsSuccess(trips: _trips, pagination: _pagination));
    } catch (_) {
      emit((state as DynaTripsSuccess).copyWith(loadingMore: false));
    } finally {
      _loadingMore = false;
    }
  }
}