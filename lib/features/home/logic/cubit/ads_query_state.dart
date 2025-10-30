import 'package:mushtary/features/home/data/models/ads_filter.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';

abstract class AdsQueryState {}

class AdsQueryInitial extends AdsQueryState {
  final AdsFilter filter;
  AdsQueryInitial(this.filter);
}

class AdsQueryLoading extends AdsQueryState {}

class AdsQuerySuccess extends AdsQueryState {
  final List<HomeAdModel> items;
  final AdsFilter filter;
  final bool isListView;

  AdsQuerySuccess(
      this.items, {
        required this.filter,
        this.isListView = false,
      });

  AdsQuerySuccess copyWith({
    List<HomeAdModel>? items,
    AdsFilter? filter,
    bool? isListView,
  }) {
    return AdsQuerySuccess(
      items ?? this.items,
      filter: filter ?? this.filter,
      isListView: isListView ?? this.isListView,
    );
  }
}

class AdsQueryEmpty extends AdsQueryState {}

class AdsQueryFailure extends AdsQueryState {
  final String message;
  AdsQueryFailure(this.message);
}