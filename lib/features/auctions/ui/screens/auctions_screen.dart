import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/features/auctions/ui/widgets/auction_grid_view_item.dart';
import 'package:mushtary/features/auctions/ui/widgets/auction_grid_view_item_with_highest_auction.dart';
import 'package:mushtary/features/auctions/ui/widgets/auction_list_view_item.dart';
import 'package:mushtary/features/auctions/ui/widgets/auction_list_view_item_with_heighst_auction.dart';

class AuctionsScreen extends StatelessWidget {
  const AuctionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.w,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    if (index % 2 == 0) {
                      return const AuctionGridViewItemWithHighestAuction();
                    } else {
                      return const AuctionGridViewItem();
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (index % 2 == 0) {
                      return const AuctionListViewItem();
                    } else {
                      return const AuctionListViewItemWithHeighstAuction();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
