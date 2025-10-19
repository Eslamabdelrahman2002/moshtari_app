import 'package:equatable/equatable.dart';
import '../../../data/model/received_offer_models.dart';

class ProviderOffersState extends Equatable {
  final bool loading;
  final String? error;
  final List<ReceivedOffer> offers;

  // لحالة زر قبول/رفض لعرض معيّن
  final int? actingOfferId;
  final bool actionLoading;

  const ProviderOffersState({
    this.loading = false,
    this.error,
    this.offers = const [],
    this.actingOfferId,
    this.actionLoading = false,
  });

  ProviderOffersState copyWith({
    bool? loading,
    String? error,
    List<ReceivedOffer>? offers,
    int? actingOfferId,
    bool? actionLoading,
    bool clearError = false,
  }) {
    return ProviderOffersState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      offers: offers ?? this.offers,
      actingOfferId: actingOfferId,
      actionLoading: actionLoading ?? this.actionLoading,
    );
  }

  @override
  List<Object?> get props => [loading, error, offers, actingOfferId, actionLoading];
}