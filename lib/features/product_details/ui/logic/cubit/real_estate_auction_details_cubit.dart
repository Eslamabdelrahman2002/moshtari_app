// lib/features/real_estate_auctions/ui/logic/cubit/real_estate_auction_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/real_estate_auction_repo.dart';
import 'real_estate_auction_details_state.dart';

class RealEstateAuctionDetailsCubit extends Cubit<RealEstateAuctionDetailsState> {
  final RealEstateAuctionRepo repo;
  RealEstateAuctionDetailsCubit(this.repo) : super(RealEstateAuctionDetailsInitial());

  Future<void> fetch(int id, {int? activeItemId}) async { // ✅ تعديل التوقيع
    emit(RealEstateAuctionDetailsLoading());
    try {
      final data = await repo.fetch(id, activeItemId: activeItemId); // ✅ تمرير للريبو
      emit(RealEstateAuctionDetailsSuccess(data));
    } catch (e) {
      emit(RealEstateAuctionDetailsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}