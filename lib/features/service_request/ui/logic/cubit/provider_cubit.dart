import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/service_request/ui/logic/cubit/provider_state.dart';
import '../../../data/repo/provider_repo.dart';


class ProviderOffersCubit extends Cubit<ProviderOffersState> {
  final ProviderRepo _repo;
  ProviderOffersCubit(this._repo) : super(const ProviderOffersState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.fetchMyReceivedOffers();
      emit(state.copyWith(loading: false, offers: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> accept(int offerId) async {
    emit(state.copyWith(actingOfferId: offerId, actionLoading: true, clearError: true));
    try {
      await _repo.acceptOffer(offerId);
      // بعد النجاح أعد التحميل أو حدث القائمة محلياً
      await load();
      emit(state.copyWith(actingOfferId: null, actionLoading: false));
    } catch (e) {
      emit(state.copyWith(actingOfferId: null, actionLoading: false, error: e.toString()));
    }
  }

  Future<void> reject(int offerId) async {
    emit(state.copyWith(actingOfferId: offerId, actionLoading: true, clearError: true));
    try {
      await _repo.rejectOffer(offerId);
      await load();
      emit(state.copyWith(actingOfferId: null, actionLoading: false));
    } catch (e) {
      emit(state.copyWith(actingOfferId: null, actionLoading: false, error: e.toString()));
    }
  }
}