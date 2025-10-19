import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/auctions/ui/widgets/highest_auction.dart';

class AuctionListViewItemWithHeighstAuction extends StatelessWidget {
  const AuctionListViewItemWithHeighstAuction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3.73,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.w),
        padding: EdgeInsets.all(8.w),
        height: 110.w,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            //data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //title
                  Text(
                    'سوبارو امبريزا (2022) أزرق جديدة',
                    style: TextStyles.font14Black500Weight,
                  ),

                  //status
                  Row(
                    children: [
                      SizedBox(
                        width: 77.w,
                        child: Row(
                          children: [
                            MySvg(
                              image: 'location-dark',
                              width: 12.w,
                              height: 12.w,
                            ),
                            horizontalSpace(4),
                            Expanded(
                              child: Text(
                                'الرياض',
                                style: TextStyles.font10Dark400Grey400Weight,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpace(16),
                      MySvg(
                        image: 'steering-wheel',
                        width: 12.w,
                        height: 12.w,
                      ),
                      Text(
                        'سيارات',
                        style: TextStyles.font10Secondary500700Weight,
                      ),
                      horizontalSpace(4),
                      Text(
                        '( 24  سيارة )',
                        style: TextStyles.font10Error500500Weight,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 70.w,
                        child: Row(
                          children: [
                            MySvg(
                              image: 'user',
                              width: 12.w,
                              height: 12.w,
                            ),
                            horizontalSpace(4),
                            Expanded(
                              child: Text(
                                'اسم المستخدم',
                                style: TextStyles.font10Dark400Grey400Weight,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpace(16),
                      const HighestAuction(),
                    ],
                  )
                ],
              ),
            ),
            //image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/mushtary-5ef7f.appspot.com/o/2024-bmw-x6-112-1675791922.jpg?alt=media&token=ecfd40b9-ab72-4ade-99dc-0e38db3ae2c3',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
