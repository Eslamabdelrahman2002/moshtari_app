import 'package:equatable/equatable.dart';
import '../../model/data/my_requests_models.dart';

class MyRequestsState extends Equatable {
  final bool loading;
  final String? error;
  final List<ServiceRequestItem> requests;
  final int? actingOfferId;
  final String serviceFilter; // all | dyna | flatbed | tanker

  const MyRequestsState({
    this.loading = false,
    this.error,
    this.requests = const [],
    this.actingOfferId,
    this.serviceFilter = 'all',
  });

  MyRequestsState copyWith({
    bool? loading,
    String? error,
    List<ServiceRequestItem>? requests,
    int? actingOfferId,
    String? serviceFilter,
    bool clearError = false,
  }) {
    return MyRequestsState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      requests: requests ?? this.requests,
      actingOfferId: actingOfferId,
      serviceFilter: serviceFilter ?? this.serviceFilter,
    );
  }

  @override
  List<Object?> get props => [loading, error, requests, actingOfferId, serviceFilter];
}