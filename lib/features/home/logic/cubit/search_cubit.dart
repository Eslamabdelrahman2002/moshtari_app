import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/home/data/models/ads_filter.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/data/repo/home_repo.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final HomeRepo _repo;
  AdsFilter _filter = AdsFilter();

  SearchCubit(this._repo) : super(SearchInitial(AdsFilter()));

  AdsFilter get filter => _filter;

  Future<void> setLayout(bool isList) async {
    final s = state;
    if (s is SearchSuccess) emit(s.copyWith(isListView: isList));
  }

  Future<void> search({String? query, AdsFilter? filter}) async {
    final f = (filter ?? _filter).copyWith(query: query);
    _filter = f;
    emit(SearchLoading());
    try {
      final items = await _repo.searchAds(f);
      if (items.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchSuccess(items, filter: f));
      }
    } catch (e) {
      emit(SearchFailure(e.toString()));
    }
  }

  Future<void> applyFilter(AdsFilter filter) => search(filter: filter, query: filter.query);
}