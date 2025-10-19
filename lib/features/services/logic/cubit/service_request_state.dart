abstract class ServiceRequestState {
  const ServiceRequestState();
}
class ServiceRequestInitial extends ServiceRequestState {
  const ServiceRequestInitial();
}
class ServiceRequestLoading extends ServiceRequestState {
  const ServiceRequestLoading();
}
class ServiceRequestSuccess extends ServiceRequestState {
  final String message;
  const ServiceRequestSuccess(this.message);
}
class ServiceRequestFailure extends ServiceRequestState {
  final String error;
  const ServiceRequestFailure(this.error);
}