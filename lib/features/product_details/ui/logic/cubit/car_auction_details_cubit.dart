// lib/features/car_auctions/ui/logic/cubit/car_auction_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/car_auction_repo.dart';
import 'car_auction_details_state.dart';

class CarAuctionDetailsCubit extends Cubit<CarAuctionDetailsState> {
  final CarAuctionRepo repo;
  CarAuctionDetailsCubit(this.repo) : super(CarAuctionDetailsInitial());

  Future<void> fetchAuction(int id) async {
    emit(CarAuctionDetailsLoading());
    try {
      final data = await repo.fetchCarAuction(id);
      emit(CarAuctionDetailsSuccess(data));
    } catch (e) {
      emit(CarAuctionDetailsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}