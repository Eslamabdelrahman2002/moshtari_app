import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/services/logic/cubit/service_providers_state.dart';
import '../../data/model/service_provider_model.dart';
import '../../data/repo/service_providers_repo.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class ServiceProvidersCubit extends Cubit<ServiceProvidersState> {
  final ServiceProvidersRepo repo;
  ServiceProvidersCubit(this.repo) : super(const ServiceProvidersState());

  Future<void> fetch({required int labourId, int page = 1, int pageSize = 10}) async {
    emit(state.copyWith(loading: true, error: null));
    debugPrint('Fetching providers from API for labourId: $labourId, page: $page');
    try {
      final data = await repo.fetchByLabour(labourId: labourId, page: page, pageSize: pageSize);
      debugPrint('API Fetched Providers: ${data.length} items');
      if (data.isNotEmpty) {
        debugPrint('First Provider: ID=${data.first.id}, Name=${data.first.fullName}, LabourId=${data.first.labourId}');
      } else {
        debugPrint('No providers returned from API for labourId: $labourId');
      }
      emit(state.copyWith(loading: false, items: data));
    } catch (e) {
      debugPrint('Error fetching providers from API: $e');
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clear() => emit(const ServiceProvidersState());
}