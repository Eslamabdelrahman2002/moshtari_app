abstract class OfferState {}

class OfferInitial extends OfferState {}

class OfferLoading extends OfferState {}

class OfferSuccess extends OfferState {
  final String message;
  OfferSuccess(this.message);
}

class OfferFailure extends OfferState {
  final String error;
  OfferFailure(this.error);
}