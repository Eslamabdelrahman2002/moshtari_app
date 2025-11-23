import 'package:equatable/equatable.dart';
import 'package:mushtary/features/service_profile/data/model/received_offer.dart';

class ServiceOffersState extends Equatable {
  final bool loading;
  final String? error;
  final bool success;

  /// آخر عرض تم إنشاؤه (Submit)
  final ReceivedOffer? lastCreatedOffer;

  /// Id العرض الذي تُجرى عليه عملية حالياً (accept/reject)
  final int? actingOfferId;

  const ServiceOffersState({
    this.loading = false,
    this.error,
    this.success = false,
    this.lastCreatedOffer,
    this.actingOfferId,
  });

  ServiceOffersState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    bool? success,
    ReceivedOffer? lastCreatedOffer,
    bool clearLastCreated = false,
    int? actingOfferId,
    bool clearActing = false,
  }) {
    return ServiceOffersState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
      lastCreatedOffer:
      clearLastCreated ? null : (lastCreatedOffer ?? this.lastCreatedOffer),
      actingOfferId:
      clearActing ? null : (actingOfferId ?? this.actingOfferId),
    );
  }

  @override
  List<Object?> get props => [
    loading,
    error,
    success,
    lastCreatedOffer,
    actingOfferId,
  ];
}