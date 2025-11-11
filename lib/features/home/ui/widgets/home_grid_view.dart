  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:mushtary/features/home/ui/widgets/grid_view_item.dart';
  import '../../data/models/home_data_model.dart';
import 'auction_grid_item.dart';
  
  class HomeGridView extends StatelessWidget {
    final List<HomeAdModel> ads;
    final bool isLoading;
  
    const HomeGridView({
      super.key,
      required this.ads,
      this.isLoading = false,
    });
  
    @override
    Widget build(BuildContext context) {
      if (isLoading) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
        );
      }
  
      if (ads.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('لا توجد عناصر للعرض')),
          ),
        );
      }

      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 18.h,
          childAspectRatio: 0.9,
          crossAxisCount: 2,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final ad = ads[index];
            final isAuction = ad.auctionDisplayType != null;
            if (isAuction) {
              return AuctionGridItem(adModel: ad); // 👈 الكارت الجديد
            }
            return GridViewItem(adModel: ad); // الكارت العادي
          },
          childCount: ads.length,
        ),
      );
    }
  }