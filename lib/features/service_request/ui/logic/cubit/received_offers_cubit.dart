import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/received_offer_models.dart';
import '../../../data/repo/received_offers_repo.dart';
import 'received_offers_state.dart';

class ReceivedOffersCubit extends Cubit<ReceivedOffersState> {
  final ReceivedOffersRepo _repo;
  ReceivedOffersCubit(this._repo) : super(const ReceivedOffersState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.fetchMyReceivedOffers();
      emit(state.copyWith(loading: false, offers: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<bool> accept(int offerId) async {
    emit(state.copyWith(actingOfferId: offerId, error: null));
    try {
      final reqStatus = await _repo.acceptOffer(offerId); // in_progress غالبًا
      final updated = state.offers.map((o) {
        if (o.offerId == offerId) {
          // 💡 هنا يجب أن نعيد بناء العرض مع isVerified لكي لا نفقده
          return ReceivedOffer(
            offerId: o.offerId,
            price: o.price,
            status: 'accepted',
            createdAt: o.createdAt,
            serviceType: o.serviceType,
            requestStatus: reqStatus ?? 'in_progress',
            providerId: o.providerId,
            fullName: o.fullName,
            personalImage: o.personalImage,
            isVerified: o.isVerified, // 🟢 الحفاظ على حالة التوثيق
          );
        }
        return o;
      }).toList();

      emit(state.copyWith(actingOfferId: null, offers: updated));
      return true;
    } catch (e) {
      emit(state.copyWith(actingOfferId: null, error: e.toString()));
      return false;
    }
  }
}