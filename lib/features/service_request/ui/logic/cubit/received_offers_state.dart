import '../../../data/model/received_offer_models.dart';


class ReceivedOffersState {
  final bool loading;
  final String? error;
  final List<ReceivedOffer> offers;
  final int? actingOfferId; // العرض الجاري تنفيذ طلب عليه (accept)

  const ReceivedOffersState({
    this.loading = false,
    this.error,
    this.offers = const [],
    this.actingOfferId,
  });

  ReceivedOffersState copyWith({
    bool? loading,
    String? error,
    List<ReceivedOffer>? offers,
    int? actingOfferId,
  }) {
    return ReceivedOffersState(
      loading: loading ?? this.loading,
      error: error,
      offers: offers ?? this.offers,
      actingOfferId: actingOfferId,
    );
  }
}