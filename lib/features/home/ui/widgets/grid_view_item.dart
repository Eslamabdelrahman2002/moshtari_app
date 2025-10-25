import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/router/routes.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_state.dart';
import '../../data/models/home_data_model.dart';
import '../../../../core/utils/helpers/spacing.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GridViewItem extends StatelessWidget {
  final HomeAdModel adModel;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  const GridViewItem({
    super.key,
    required this.adModel,
    this.isFavorited = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());

    final hasImage = adModel.imageUrls.isNotEmpty;
    final imageUrl = hasImage ? adModel.imageUrls.first : '';
    final isAuction = adModel.auctionDisplayType != null;
    final favoriteType = isAuction ? 'auction' : 'ad';
    final favId = isAuction ? (adModel.auctionId ?? adModel.id) : adModel.id;

    final created = DateTime.tryParse(adModel.createdAt);
    final createdAgo = created != null ? timeago.format(created, locale: 'ar') : '';

    return InkWell(
      onTap: () {
        if (isAuction) {
          if (adModel.categoryId == 1) {
            Navigator.of(context).pushNamed(Routes.carAuctionDetailsScreen, arguments: adModel.auctionId ?? adModel.id);
          } else if (adModel.categoryId == 2) {
            Navigator.of(context).pushNamed(Routes.realEstateAuctionDetailsScreen, arguments: adModel.auctionId ?? adModel.id);
          }
          return;
        }

        switch (adModel.sourceType) {
          case 'car_ads':
            Navigator.of(context).pushNamed(Routes.carDetailsScreen, arguments: adModel.id);
            break;
          case 'real_estate_ads':
            Navigator.of(context).pushNamed(Routes.realEstateDetailsScreen, arguments: adModel.id);
            break;
          case 'car_parts_ads':
          case 'car_part_ads':
            Navigator.of(context).pushNamed(Routes.carPartDetailsScreen, arguments: adModel.id);
            break;
          case 'other_ads':
          default:
            Navigator.of(context).pushNamed(Routes.otherAdDetailsScreen, arguments: adModel.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16.r, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: hasImage
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        // Skeletonizer بدل الـ CircularProgressIndicator
                        placeholder: (_, __) => Skeletonizer(
                          enabled: true,
                          child: Container(color: ColorsManager.grey200),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: ColorsManager.grey200,
                          child: const Icon(Icons.error),
                        ),
                      )
                          : Container(
                        color: ColorsManager.grey200,
                        child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  if (isAuction)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Row(
                        children: [
                          _tag('single' == adModel.auctionDisplayType ? 'فردي' : 'متعدد', ColorsManager.success500),
                          horizontalSpace(4),
                          _tag('مزاد حي', ColorsManager.redButton),
                        ],
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, state) {
                        bool isFav = isFavorited;
                        if (state is FavoritesLoaded) {
                          isFav = state.favoriteIds.contains(favId);
                        }
                        return GestureDetector(
                          onTap: onFavoriteTap ?? () => context.read<FavoritesCubit>().toggleFavorite(type: favoriteType, id: favId),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: MySvg(
                              image: "favourite",
                              width: 20,
                              height: 20,
                              color: isFav ? ColorsManager.redButton : Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(8),
            Text(
              adModel.title.isEmpty ? 'No Title' : adModel.title,
              style: TextStyles.font12Black400Weight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpace(8),
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ListViewItemDataWidget(image: 'location-dark', text: adModel.location),
                    verticalSpace(4),
                    ListViewItemDataWidget(image: 'user', text: adModel.username),
                  ]),
                ),
                horizontalSpace(8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ListViewItemDataWidget(
                      image: 'riyal_black',
                      isColoredText: true,
                      text: (adModel.price?.trim().isEmpty ?? true) ? 'N/A' : adModel.price!,
                    ),
                    verticalSpace(4),
                    ListViewItemDataWidget(image: 'clock', text: createdAgo),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.r)),
    child: Text(text, style: TextStyles.font10White500Weight),
  );
}