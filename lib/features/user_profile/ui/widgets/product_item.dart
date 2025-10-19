import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/data/models/auctions/auctions_model.dart';
import '../../data/model/my_ads_model.dart';
import '../../data/model/my_auctions_model.dart';

class ProductItem extends StatelessWidget {
  final dynamic model; // يمكن أن يكون MyAdsModel أو MyAuctionModel
  const ProductItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final title = (model is MyAdsModel) ? model.title : (model is MyAuctionModel ? model.title : '');
    final price = (model is MyAdsModel) ? model.price : (model is MyAuctionModel ? model.startingPrice : '');
    final createdAt = (model is MyAdsModel) ? model.createdAt : (model is MyAuctionModel ? model.createdAt : '');
    final images = (model is MyAdsModel) ? model.imageUrls : (model is MyAuctionModel ? model.imageUrls : []);
    final ownerName = (model is MyAdsModel) ? model.ownerName : (model is MyAuctionModel ? model.ownerName : '');
    final ownerPicture = (model is MyAdsModel) ? model.ownerPicture : (model is MyAuctionModel ? model.ownerPicture : '');

    return Container(

      padding: EdgeInsets.all(8.r),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.font12Black400Weight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace(16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          MySvg(image: 'clock', width: 12.w, height: 12.w),
                          horizontalSpace(4),
                          Flexible(
                            child: Text(
                              createdAt,
                              style: TextStyles.font10Dark600Grey400Weight,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    horizontalSpace(8),
                    Expanded(
                      child: Row(
                        children: [
                          MySvg(image: 'riyal_black', width: 12.w, height: 12.w),
                          horizontalSpace(4),
                          Flexible(
                            child: Text(
                              price,
                              style: TextStyles.font10Primary400Weight,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          horizontalSpace(8),
          if (images.isNotEmpty)
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: images.first,
                  height: 70.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
        ],
      )
      ,
    );

  }
}
