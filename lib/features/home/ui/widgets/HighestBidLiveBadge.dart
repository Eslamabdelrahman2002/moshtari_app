import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/utils/helpers/spacing.dart';
import '../../../../core/widgets/primary/my_svg.dart';
import '../../../product_details/data/repo/auction_bid_repo.dart';
import '../../../product_details/ui/logic/cubit/auction_bid_cubit.dart';

class HighestBidLivePill extends StatefulWidget {
  final int auctionId;
  final String auctionType; // car | real_estate | other
  final int itemId;
  final num initialMaxBid;

  const HighestBidLivePill({
    super.key,
    required this.auctionId,
    required this.auctionType,
    required this.itemId,
    required this.initialMaxBid,
  });

  @override
  State<HighestBidLivePill> createState() => _HighestBidLivePillState();
}

class _HighestBidLivePillState extends State<HighestBidLivePill> {
  late final AuctionBidCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AuctionBidCubit(
      getIt<AuctionBidRepo>(),
      auctionId: widget.auctionId,
      auctionType: widget.auctionType,
      itemId: widget.itemId,
      currentMaxBid: widget.initialMaxBid,
    );
    _cubit.joinAuction();
  }

  @override
  void dispose() {
    _cubit.leaveAuction();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuctionBidCubit, AuctionBidState>(
      bloc: _cubit,
      buildWhen: (p, c) => p.currentMaxBid != c.currentMaxBid,
      builder: (context, state) {
        final v = state.currentMaxBid;
        if (v <= 0) return const SizedBox.shrink();

        final value = NumberFormat.decimalPattern('ar').format(v);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5C6BF6), Color(0xFF3F51F3)]),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MySvg(image: 'saudi_riyal', width: 14, height: 14, color: Colors.white),
              horizontalSpace(8),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
              horizontalSpace(12),
              Row(
                children: [
                  Icon(Icons.local_offer_rounded, size: 14, color: Colors.white),
                  horizontalSpace(4),
                  Text('أعلى مزايدة', style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 11.sp)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}