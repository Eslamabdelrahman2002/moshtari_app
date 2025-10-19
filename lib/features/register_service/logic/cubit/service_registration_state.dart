import '../../data/model/service_registration_model.dart';

abstract class ServiceRegistrationState {}

class ServiceRegistrationInitial extends ServiceRegistrationState {}
class ServiceRegistrationReady extends ServiceRegistrationState {}
class ServiceRegistrationUpdated extends ServiceRegistrationState {
  final ServiceProviderRegistrationModel model;
  ServiceRegistrationUpdated(this.model);
}
class ServiceRegistrationLoading extends ServiceRegistrationState {}
class ServiceRegistrationSuccess extends ServiceRegistrationState {}
class ServiceRegistrationFailure extends ServiceRegistrationState {
  final String error;
  ServiceRegistrationFailure(this.error);
}