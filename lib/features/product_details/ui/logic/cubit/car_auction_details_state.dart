// lib/features/car_auctions/ui/logic/cubit/car_auction_details_state.dart

import '../../../data/model/car_auction_details_model.dart';

abstract class CarAuctionDetailsState {}

class CarAuctionDetailsInitial extends CarAuctionDetailsState {}

class CarAuctionDetailsLoading extends CarAuctionDetailsState {}

class CarAuctionDetailsSuccess extends CarAuctionDetailsState {
  final CarAuctionDetailsModel details;
  CarAuctionDetailsSuccess(this.details);
}

class CarAuctionDetailsFailure extends CarAuctionDetailsState {
  final String message;
  CarAuctionDetailsFailure(this.message);
}