// lib/features/product_details/ui/logic/cubit/auction_bid_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/product_details/data/repo/auction_bid_repo.dart';

import '../../../data/model/place_bid_result.dart';

// ================= States =================

abstract class AuctionBidState {
  final num currentMaxBid;
  const AuctionBidState(this.currentMaxBid);
}

class AuctionBidInitial extends AuctionBidState { const AuctionBidInitial(num v) : super(v); }
class AuctionBidLoading extends AuctionBidState { const AuctionBidLoading(num v) : super(v); }
class AuctionBidUpdated extends AuctionBidState { const AuctionBidUpdated(num v) : super(v); }

class AuctionBidSuccess extends AuctionBidState {
  final num placedAmount;
  const AuctionBidSuccess(num v, this.placedAmount) : super(v);
}

class AuctionBidFailure extends AuctionBidState {
  final String message;
  const AuctionBidFailure(num v, this.message) : super(v);
}

// ================= Cubit =================

class AuctionBidCubit extends Cubit<AuctionBidState> {
  final AuctionBidRepo _repo;
  final int auctionId;
  final String auctionType;
  final int itemId;

  num currentMaxBid;

  AuctionBidCubit(
      this._repo, {
        required this.auctionId,
        required this.auctionType,
        required this.itemId,
        required this.currentMaxBid,
      }) : super(AuctionBidInitial(currentMaxBid));

  // يُستدعى عند بث updateMaxBid من السوكت
  void updateMaxBid(num maxBid) {
    if (maxBid > currentMaxBid) {
      currentMaxBid = maxBid;
      emit(AuctionBidUpdated(currentMaxBid));
    }
  }

  Future<void> placeBid({required num bidAmount}) async {
    emit(AuctionBidLoading(currentMaxBid));
    try {
      final PlaceBidResult res = await _repo.placeBid(
        auctionId: auctionId,
        bidAmount: bidAmount,
        auctionType: auctionType,
        itemId: itemId,
      );

      if (res.success) {
        // 1) حدّث حسب maxBid من السيرفر إن توفرت
        final serverMax = res.maxBid;
        if (serverMax != null && serverMax > currentMaxBid) {
          currentMaxBid = serverMax;
          emit(AuctionBidUpdated(currentMaxBid));
        } else if (bidAmount > currentMaxBid) {
          // 2) بديل تفاؤلي لو السيرفر لم يرجّع maxBid
          currentMaxBid = bidAmount;
          emit(AuctionBidUpdated(currentMaxBid));
        }

        // حالة نجاح (قد تستخدمها لغلق الديالوج)
        emit(AuctionBidSuccess(currentMaxBid, bidAmount));
      } else {
        emit(AuctionBidFailure(currentMaxBid, res.message ?? 'فشل إرسال المزايدة. يرجى المحاولة مرة أخرى.'));
      }
    } catch (_) {
      emit(AuctionBidFailure(currentMaxBid, 'حدث خطأ أثناء الاتصال بالخادم.'));
    }
  }

  void joinAuction() => _repo.joinAuction(auctionId: auctionId, auctionType: auctionType);
  void leaveAuction() => _repo.leaveAuction(auctionId: auctionId, auctionType: auctionType);
}