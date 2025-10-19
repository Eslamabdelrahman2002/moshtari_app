import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/services/logic/cubit/service_request_state.dart';

import '../../data/model/service_request_payload.dart';
import '../../data/repo/service_request_repo.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  final ServiceRequestRepo _repo;
  ServiceRequestCubit(this._repo) : super(const ServiceRequestInitial());

  Future<void> create(CreateServiceRequest req) async {
    emit(const ServiceRequestLoading());
    try {
      final res = await _repo.create(req);
      final msg = (res['message'] ?? 'تم إرسال الطلب بنجاح').toString();
      emit(ServiceRequestSuccess(msg));
    } catch (e) {
      emit(ServiceRequestFailure(e.toString()));
    }
  }
}