import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/auctions/ui/widgets/highest_auction.dart';
import 'package:mushtary/features/auctions/ui/widgets/status.dart';

class AuctionGridViewItemWithHighestAuction extends StatelessWidget {
  const AuctionGridViewItemWithHighestAuction({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: Container(
        width: 171.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            //image
            Flexible(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      height: 155.w,
                      fit: BoxFit.cover,
                      imageUrl:
                          'https://firebasestorage.googleapis.com/v0/b/mushtary-5ef7f.appspot.com/o/2024-bmw-x6-112-1675791922.jpg?alt=media&token=ecfd40b9-ab72-4ade-99dc-0e38db3ae2c3',
                    ),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: SizedBox(
                            width: 73.w, height: 24, child: const Status()),
                      )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 24.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: ColorsManager.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MySvg(image: 'timer-error'),
                          horizontalSpace(4),
                          Baseline(
                            baseline: 12.w,
                            baselineType: TextBaseline.alphabetic,
                            child: Text(
                              '3 يوم 21 ساعة 16 دقيقة',
                              style: TextStyles.font10Error500500Weight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(8),
            //data
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //title
                  Text(
                    'سوبارو امبريزا (2022)',
                    style: TextStyles.font12Black400Weight,
                  ),

                  Row(
                    children: [
                      MySvg(
                        image: 'user',
                        width: 12.w,
                        height: 12.w,
                      ),
                      horizontalSpace(4),
                      Flexible(
                        child: Text(
                          'اسم المستخدم',
                          style: TextStyles.font10Dark400Grey400Weight,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      horizontalSpace(4),
                      MySvg(
                        image: 'location-dark',
                        width: 12.w,
                        height: 12.w,
                      ),
                      horizontalSpace(4),
                      Flexible(
                        child: Text(
                          'الرياض',
                          style: TextStyles.font10Dark400Grey400Weight,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const HighestAuction()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
