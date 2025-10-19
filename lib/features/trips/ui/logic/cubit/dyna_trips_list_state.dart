import 'package:equatable/equatable.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';
import '../../../data/model/dyna_trips_list_models.dart';


class DynaTripsListState extends Equatable {
  final bool loading;
  final bool loadingMore;
  final String? error;
  final List<DynaTripItem> items;
  final int page;
  final int pageSize;
  final int totalPages;

  final City? fromCity;
  final City? toCity;

  const DynaTripsListState({
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.items = const [],
    this.page = 1,
    this.pageSize = 10,
    this.totalPages = 1,
    this.fromCity,
    this.toCity,
  });

  bool get hasMore => page < totalPages;

  DynaTripsListState copyWith({
    bool? loading,
    bool? loadingMore,
    String? error,
    List<DynaTripItem>? items,
    int? page,
    int? pageSize,
    int? totalPages,
    City? fromCity,
    City? toCity,
    bool clearError = false,
  }) {
    return DynaTripsListState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
    );
  }

  @override
  List<Object?> get props => [loading, loadingMore, error, items, page, pageSize, totalPages, fromCity, toCity];
}