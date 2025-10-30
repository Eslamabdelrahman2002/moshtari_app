import 'package:mushtary/features/home/data/models/ads_filter.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {
  final AdsFilter filter;
  SearchInitial(this.filter);
}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<HomeAdModel> items;
  final AdsFilter filter;
  final bool isListView;
  SearchSuccess(this.items, {required this.filter, this.isListView = false});

  SearchSuccess copyWith({List<HomeAdModel>? items, AdsFilter? filter, bool? isListView}) {
    return SearchSuccess(items ?? this.items,
        filter: filter ?? this.filter, isListView: isListView ?? this.isListView);
  }
}

class SearchEmpty extends SearchState {}

class SearchFailure extends SearchState {
  final String message;
  SearchFailure(this.message);
}