import 'package:equatable/equatable.dart';
import '../../../data/model/received_offer_models.dart';

class ReceivedOffersState extends Equatable {
  final bool loading;
  final List<ReceivedOffer> offers;
  final int? actingOfferId; // العرض الجاري تنفيذ إجراء عليه (قبول/رفض)
  final String? error;

  const ReceivedOffersState({
    this.loading = false,
    this.offers = const [],
    this.actingOfferId,
    this.error,
  });

  ReceivedOffersState copyWith({
    bool? loading,
    List<ReceivedOffer>? offers,
    int? actingOfferId,
    String? error,
    bool clearError = false,
    bool keepActingOfferId = false,
  }) {
    return ReceivedOffersState(
      loading: loading ?? this.loading,
      offers: offers ?? this.offers,
      actingOfferId: keepActingOfferId ? this.actingOfferId : actingOfferId,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [loading, offers, actingOfferId, error];
}