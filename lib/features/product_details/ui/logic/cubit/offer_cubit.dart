import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/offer_request.dart';
import '../../../data/repo/offers_repo.dart';
import 'offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OffersRepo _repo;
  OfferCubit(this._repo) : super(OfferInitial());

  Future<void> sendOffer(OfferRequest request) async {
    emit(OfferLoading());
    try {
      final msg = await _repo.submitOffer(request);
      emit(OfferSuccess(msg));
    } catch (e) {
      emit(OfferFailure(e.toString()));
    }
  }
}