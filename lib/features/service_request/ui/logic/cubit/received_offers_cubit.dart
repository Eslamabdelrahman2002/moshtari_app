import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/received_offer_models.dart';
import '../../../data/repo/received_offers_repo.dart';
import 'received_offers_state.dart';

class ReceivedOffersCubit extends Cubit<ReceivedOffersState> {
  final ReceivedOffersRepo _repo;
  ReceivedOffersCubit(this._repo) : super(const ReceivedOffersState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true, keepActingOfferId: true));
    try {
      final list = await _repo.fetchMyReceivedOffers();
      emit(state.copyWith(loading: false, offers: list, keepActingOfferId: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString(), keepActingOfferId: true));
    }
  }

  Future<bool> accept(int offerId) async {
    emit(state.copyWith(actingOfferId: offerId, clearError: true));
    try {
      final reqStatus = await _repo.acceptOffer(offerId); // غالباً in_progress
      final updated = state.offers.map((o) {
        if (o.offerId == offerId) {
          return ReceivedOffer(
            offerId: o.offerId,
            price: o.price,
            status: 'accepted',
            createdAt: o.createdAt,
            serviceType: o.serviceType,
            requestStatus: reqStatus ?? o.requestStatus,
            providerId: o.providerId,
            fullName: o.fullName,
            personalImage: o.personalImage,
            isVerified: o.isVerified,
          );
        }
        return o;
      }).toList();
      emit(state.copyWith(offers: updated, actingOfferId: null));
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
      final updated = state.offers.map((o) {
        if (o.offerId == offerId) {
          return ReceivedOffer(
            offerId: o.offerId,
            price: o.price,
            status: 'rejected',
            createdAt: o.createdAt,
            serviceType: o.serviceType,
            requestStatus: o.requestStatus,
            providerId: o.providerId,
            fullName: o.fullName,
            personalImage: o.personalImage,
            isVerified: o.isVerified,
          );
        }
        return o;
      }).toList();
      emit(state.copyWith(offers: updated, actingOfferId: null));
      return true;
    } catch (e) {
      emit(state.copyWith(actingOfferId: null, error: e.toString()));
      return false;
    }
  }
}