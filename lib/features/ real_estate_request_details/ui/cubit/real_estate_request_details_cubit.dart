// file: features/real_estate_requests/logic/cubit/real_estate_request_details_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/real_estate_requests_repo.dart';
import 'real_estate_request_details_state.dart';

class RealEstateRequestDetailsCubit extends Cubit<RealEstateRequestDetailsState> {
  final RealEstateRequestsRepo _repo;
  RealEstateRequestDetailsCubit(this._repo) : super(const RequestDetailsInitial());

  Future<void> fetch(int id) async {
    emit(const RequestDetailsLoading());
    try {
      final details = await _repo.getRequestDetails(id);
      emit(RequestDetailsSuccess(details));
    } catch (e) {
      emit(RequestDetailsFailure(e.toString()));
    }
  }
}