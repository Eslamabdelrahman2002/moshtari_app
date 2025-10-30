import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/home/data/models/ads_filter.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/data/repo/home_repo.dart';
import 'ads_query_state.dart';

class AdsQueryCubit extends Cubit<AdsQueryState> {
  final HomeRepo _repo;
  AdsFilter _filter = const AdsFilter();

  AdsQueryCubit(this._repo) : super(AdsQueryInitial(const AdsFilter()));

  AdsFilter get filter => _filter;

  // بحث نصي -> /users/search?query=
  Future<void> searchByText(String query) async {
    _filter = AdsFilter(query: query.trim());
    emit(AdsQueryLoading());
    try {
      final List<HomeAdModel> items = await _repo.searchAds(_filter);
      if (items.isEmpty) emit(AdsQueryEmpty());
      else emit(AdsQuerySuccess(items, filter: _filter));
    } catch (e) {
      emit(AdsQueryFailure(e.toString()));
    }
  }

  // فلترة -> /users/home
  Future<void> applyFilter(AdsFilter filter) async {
    _filter = filter.copyWith(query: null);
    emit(AdsQueryLoading());
    try {
      final List<HomeAdModel> items = await _repo.filterAds(_filter);
      if (items.isEmpty) emit(AdsQueryEmpty());
      else emit(AdsQuerySuccess(items, filter: _filter));
    } catch (e) {
      emit(AdsQueryFailure(e.toString()));
    }
  }

  Future<void> start({String? query, AdsFilter? filter}) async {
    if (query != null && query.trim().isNotEmpty) return searchByText(query);
    if (filter != null) return applyFilter(filter);
    emit(AdsQueryInitial(_filter));
  }

  void setLayout(bool isList) {
    final s = state;
    if (s is AdsQuerySuccess) emit(s.copyWith(isListView: isList));
  }
}