import 'package:flutter_bloc/flutter_bloc.dart';
import 'marketing_request_state.dart';
import '../../../data/repo/marketing_requests_repo.dart';

class MarketingRequestCubit extends Cubit<MarketingRequestState> {
  final MarketingRequestsRepo repo;
  MarketingRequestCubit(this.repo) : super(const MarketingRequestState());

  Future<void> submit({required int adId, required String message}) async {
    emit(state.copyWith(submitting: true, success: false, error: null, serverMessage: null));
    try {
      final res = await repo.create(adId: adId, message: message);
      emit(state.copyWith(submitting: false, success: true, serverMessage: res.message));
    } catch (e) {
      emit(state.copyWith(submitting: false, success: false, error: e.toString()));
    }
  }
}