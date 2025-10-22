// lib/features/services/logic/cubit/dyna_trips_state.dart
import '../../data/model/dinat_trip.dart';


abstract class DynaTripsState {
  const DynaTripsState();
}

class DynaTripsInitial extends DynaTripsState {
  const DynaTripsInitial();
}

class DynaTripsLoading extends DynaTripsState {
  const DynaTripsLoading();
}

class DynaTripsSuccess extends DynaTripsState {
  final List<DynaTrip> trips;
  final Pagination pagination;
  final bool loadingMore;

  const DynaTripsSuccess({
    required this.trips,
    required this.pagination,
    this.loadingMore = false,
  });

  DynaTripsSuccess copyWith({
    List<DynaTrip>? trips,
    Pagination? pagination,
    bool? loadingMore,
  }) {
    return DynaTripsSuccess(
      trips: trips ?? this.trips,
      pagination: pagination ?? this.pagination,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class DynaTripsFailure extends DynaTripsState {
  final String error;
  const DynaTripsFailure(this.error);
}