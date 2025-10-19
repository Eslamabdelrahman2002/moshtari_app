import 'package:equatable/equatable.dart';
import '../../../data/model/received_offer_models.dart';

class ReceivedOffersState extends Equatable {
  final bool loading;
  final String? error;
  final List<ReceivedOffer> offers;

  const ReceivedOffersState({
    this.loading = false,
    this.error,
    this.offers = const [],
  });

  ReceivedOffersState copyWith({
    bool? loading,
    String? error,
    List<ReceivedOffer>? offers,
    bool clearError = false,
  }) {
    return ReceivedOffersState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      offers: offers ?? this.offers,
    );
  }

  @override
  List<Object?> get props => [loading, error, offers];
}