// lib/features/services/logic/cubit/service_offer_state.dart
abstract class ServiceOfferState {
  const ServiceOfferState();
}

class ServiceOfferInitial extends ServiceOfferState {
  const ServiceOfferInitial();
}

class ServiceOfferSubmitting extends ServiceOfferState {
  const ServiceOfferSubmitting();
}

class ServiceOfferSuccess extends ServiceOfferState {
  final String message;
  const ServiceOfferSuccess(this.message);
}

class ServiceOfferFailure extends ServiceOfferState {
  final String error;
  const ServiceOfferFailure(this.error);
}