import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/register_service/logic/cubit/service_registration_state.dart';
import '../../data/model/service_registration_model.dart';
import '../../data/repo/service_registration_repo.dart';

class ServiceRegistrationCubit extends Cubit<ServiceRegistrationState> {
  final ServiceRegistrationRepo _repo;
  ServiceProviderRegistrationModel? registrationModel;

  ServiceRegistrationCubit(this._repo) : super(ServiceRegistrationInitial());

  void initialize(String serviceType) {
    registrationModel = ServiceProviderRegistrationModel(serviceType: serviceType);
    emit(ServiceRegistrationReady());
  }

  void updateData(Function(ServiceProviderRegistrationModel model) updateFunction) {
    if (registrationModel == null) return;
    updateFunction(registrationModel!);
    emit(ServiceRegistrationUpdated(registrationModel!));
  }

  Future<void> submitRegistration() async {
    if (registrationModel == null) {
      emit(ServiceRegistrationFailure('النموذج غير مهيأ.'));
      return;
    }

    emit(ServiceRegistrationLoading());
    try {
      await _repo.registerService(registrationModel!);
      emit(ServiceRegistrationSuccess());
    } catch (e) {
      emit(ServiceRegistrationFailure(e.toString()));
    }
  }
}