// lib/features/real_estate_auctions/ui/logic/cubit/real_estate_auction_details_state.dart

import '../../../data/model/real_estate_auction_details_model.dart';

abstract class RealEstateAuctionDetailsState {}

class RealEstateAuctionDetailsInitial extends RealEstateAuctionDetailsState {}

class RealEstateAuctionDetailsLoading extends RealEstateAuctionDetailsState {}

class RealEstateAuctionDetailsSuccess extends RealEstateAuctionDetailsState {
  final RealEstateAuctionDetailsModel details;
  RealEstateAuctionDetailsSuccess(this.details);
}

class RealEstateAuctionDetailsFailure extends RealEstateAuctionDetailsState {
  final String message;
  RealEstateAuctionDetailsFailure(this.message);
}