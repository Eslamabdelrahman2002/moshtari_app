import 'package:mushtary/features/product_details/data/repo/auction_socket_service.dart';

import '../model/place_bid_result.dart';

class AuctionBidRepo {
  final AuctionSocketService _socketService;

  AuctionBidRepo(this._socketService);

  void joinAuction({required int auctionId, required String auctionType}) {
    _socketService.joinAuction(auctionId: auctionId, auctionType: auctionType);
  }

  void leaveAuction({required int auctionId, required String auctionType}) {
    _socketService.leaveAuction(auctionId: auctionId, auctionType: auctionType);
  }

  Future<PlaceBidResult> placeBid({
    required int auctionId,
    required num bidAmount,
    required String auctionType,
    required int itemId,
  }) {
    return _socketService.placeBid(
      auctionId: auctionId,
      bidAmount: bidAmount,
      auctionType: auctionType,
      itemId: itemId,
    );
  }
}