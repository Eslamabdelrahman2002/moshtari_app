// file: real_estate_grid_view_item.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/currency_extension.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/utils/helpers/time_from_now.dart';
import 'package:mushtary/core/utils/json/cites_sa.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_state.dart';
import '../../data/model/real_estate_ad_model.dart';
import '../../logic/cubit/real_estate_listings_cubit.dart';

class RealEstateGridViewItem extends StatefulWidget {
  final RealEstateListModel property;

  const RealEstateGridViewItem({
    super.key,
    required this.property,
  });

  @override
  State<RealEstateGridViewItem> createState() => _RealEstateGridViewItemState();
}

class _RealEstateGridViewItemState extends State<RealEstateGridViewItem> {
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        String? type;
        try {
          // لو الكيوبت موجود في السياق
          type = context.read<RealEstateListingsCubit>().filter.type;
        } catch (_) {
          // لو مش تحت RealEstateScreen (fallback إعلان)
          type = 'ad';
        }

        final routeName = (type == 'request')
            ? Routes.realEstateRequestDetailsView
            : Routes.realEstateDetailsScreen;

        NavX(context).pushNamed(routeName, arguments: widget.property.id);
      },
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images
            Expanded(
              flex: 5,
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: widget.property.imageUrls?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.property.imageUrls![index],
                          errorWidget:(context, url, error) => const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                  if (widget.property.imageUrls != null && widget.property.imageUrls!.length > 1)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: widget.property.imageUrls!.length,
                        effect: ExpandingDotsEffect(
                          dotWidth: 6.w,
                          dotHeight: 6.h,
                          radius: 16.r,
                          spacing: 4.w,
                          expansionFactor: 2,
                          activeDotColor: ColorsManager.white,
                          dotColor: ColorsManager.dark200,
                        ),
                      ),
                    ),
                  // ربط أيقونة المفضلة بـ FavoritesCubit
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, state) {
                        // ✅ المنطق: القلب يتلون إذا كان الـ ID موجوداً في قائمة المفضلة المحملة
                        final isFav = state is FavoritesLoaded
                            ? state.favoriteIds.contains(widget.property.id)
                            : false;

                        return InkWell(
                          onTap: () {
                            // ✅ المنطق: استدعاء toggleFavorite الذي يقوم بتغيير الحالة محلياً و APIs
                            context.read<FavoritesCubit>().toggleFavorite(
                              type: 'ad',
                              id: widget.property.id!,
                            );
                          },
                         child:  MySvg(
                            image: 'favorites',
                            color: isFav ? ColorsManager.redButton : ColorsManager.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(8),
            // Data
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.title ?? 'N/A',
                    style: TextStyles.font14Black500Weight,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListViewItemDataWidget(
                              image: 'location-dark',
                              text: (widget.property.cityName != null)
                                  ? (Cites.cites
                                  .firstWhereOrNull((city) => city.id == widget.property.cityName)
                                  ?.cityNameAr ??
                                  'مدينة غير معروفة')
                                  : 'N/A',
                            ),
                            verticalSpace(4),
                            ListViewItemDataWidget(
                              image: 'user',
                              text: widget.property.username ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListViewItemDataWidget(
                              image: 'riyal_black',
                              isColoredText: true,
                              text: widget.property.price??"",
                            ),
                            verticalSpace(4),
                            ListViewItemDataWidget(
                                image: 'clock',
                                text: widget.property.createdAt?.timeSinceNow() ?? 'N/A'
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  FittedBox(
                    child: Row(
                      children: [
                        Row(
                          children: [
                            const MySvg(image: 'ruler'),
                            horizontalSpace(4),
                            Text('${widget.property.regionName ?? 0}م', style: TextStyles.font10Dark400Grey400Weight),
                          ],
                        ),
                        horizontalSpace(8),
                        Row(
                          children: [
                            const MySvg(image: 'bed'),
                            horizontalSpace(4),
                            Text('${widget.property.roomCount ?? 0} غرف', style: TextStyles.font10Dark400Grey400Weight),
                          ],
                        ),
                        horizontalSpace(8),
                        Row(
                          children: [
                            const MySvg(image: 'panio'),
                            horizontalSpace(4),
                            Text('${widget.property.bathroomCount ?? 0} حمام', style: TextStyles.font10Dark400Grey400Weight),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}