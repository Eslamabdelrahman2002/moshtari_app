import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/service_request/data/repo/received_offers_repo.dart';
import 'package:mushtary/features/service_request/ui/logic/cubit/received_offers_state.dart';

class ReceivedOffersCubit extends Cubit<ReceivedOffersState> {
  final ReceivedOffersRepo _repo;
  ReceivedOffersCubit(this._repo) : super(const ReceivedOffersState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.fetchMyReceivedOffers();
      emit(state.copyWith(loading: false, offers: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}