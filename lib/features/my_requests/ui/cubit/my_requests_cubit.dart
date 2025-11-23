import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/repo/my_requests_repo.dart';
import 'my_requests_state.dart';

class MyRequestsCubit extends Cubit<MyRequestsState> {
  final MyRequestsRepo _repo;
  MyRequestsCubit(this._repo) : super(const MyRequestsState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.fetchMyRequests();
      emit(state.copyWith(loading: false, requests: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setFilter(String filter) {
    emit(state.copyWith(serviceFilter: filter));
  }

  Future<bool> accept(int offerId) async {
    emit(state.copyWith(actingOfferId: offerId, clearError: true));
    try {
      final reqStatus = await _repo.acceptOffer(offerId);
      final updatedRequests = state.requests.map((r) {
        final hasOffer = r.offers.any((o) => o.offerId == offerId);
        if (!hasOffer) return r;
        final updatedOffers = r.offers.map((o) {
          if (o.offerId == offerId) {
            return o.copyWith(status: 'accepted');
          }
          return o;
        }).toList();
        return r.copyWith(
          offers: updatedOffers,
          requestStatus: reqStatus ?? r.requestStatus,
        );
      }).toList();

      emit(state.copyWith(actingOfferId: null, requests: updatedRequests));
      return true;
    } catch (e) {
      emit(state.copyWith(actingOfferId: null, error: e.toString()));
      return false;
    }
  }

  Future<bool> reject(int offerId) async {
    emit(state.copyWith(actingOfferId: offerId, clearError: true));
    try {
      await _repo.rejectOffer(offerId);
      final updatedRequests = state.requests.map((r) {
        final hasOffer = r.offers.any((o) => o.offerId == offerId);
        if (!hasOffer) return r;
        final updatedOffers = r.offers.map((o) {
          if (o.offerId == offerId) {
            return o.copyWith(status: 'rejected');
          }
          return o;
        }).toList();
        return r.copyWith(offers: updatedOffers);
      }).toList();

      emit(state.copyWith(actingOfferId: null, requests: updatedRequests));
      return true;
    } catch (e) {
      emit(state.copyWith(actingOfferId: null, error: e.toString()));
      return false;
    }
  }
}