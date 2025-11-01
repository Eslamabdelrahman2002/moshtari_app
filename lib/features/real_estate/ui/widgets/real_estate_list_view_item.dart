// file: real_estate_list_view_item.dart

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

class RealEstateListViewItem extends StatefulWidget {
  final RealEstateListModel property;

  const RealEstateListViewItem({super.key, required this.property});

  @override
  State<RealEstateListViewItem> createState() => _RealEstateListViewItemState();
}

class _RealEstateListViewItemState extends State<RealEstateListViewItem> {
  final PageController pageController = PageController();
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // Helper widget for placeholder
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.dark50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Container(
          width: 358.w,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Container(
                        height: 140.w,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: widget.property.imageUrls?.length ?? 0,
                          itemBuilder: (context, index) {
                            final imageUrl = widget.property.imageUrls![index];
                            final bool isValidUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: isValidUrl
                                    ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => _buildPlaceholder(),
                                  placeholder: (context, url) => _buildPlaceholder(),
                                )
                                    : _buildPlaceholder(),
                              ),
                            );
                          },
                        ),
                      ),
                      if (widget.property.imageUrls != null &&
                          widget.property.imageUrls!.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: SmoothPageIndicator(
                            controller: pageController,
                            count: widget.property.imageUrls!.length,
                            effect: ExpandingDotsEffect(
                              dotWidth: 6.w,
                              dotHeight: 6.w,
                              radius: 16,
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
                        right: 16.w,
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
                              child: MySvg(
                                image: 'favorites',
                                color: isFav ? ColorsManager.redButton : ColorsManager.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(8),
                    Text(widget.property.title ?? 'N/A',
                        style: TextStyles.font14Black500Weight),
                    verticalSpace(12),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListViewItemDataWidget(
                                image: 'location-dark',
                                text: (widget.property.regionName!= null)
                                    ? (Cites.cites
                                    .firstWhereOrNull((city) => city.id == widget.property.cityName)
                                    ?.cityNameAr ??
                                    'مدينة غير معروفة')
                                    : 'N/A',
                                width: 12,
                                height: 12),
                            verticalSpace(12),
                            ListViewItemDataWidget(
                                image: 'user',
                                text: widget.property.username ?? 'N/A',
                                width: 12,
                                height: 12),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListViewItemDataWidget(
                              image: 'riyal_new',
                              isColoredText: true,
                              text: widget.property.price??"" ,
                            ),
                            verticalSpace(12),
                            ListViewItemDataWidget(
                                image: 'clock',
                                text: widget.property.createdAt?.timeSinceNow() ?? 'N/A'
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpace(8),
                    Row(
                      children: [
                        Chip(
                          label: Row(
                            children: [
                              const MySvg(image: 'ruler'),
                              horizontalSpace(8),
                              Text('${widget.property.cityName ?? 0}م',
                                  style: TextStyles.font10Dark400Grey400Weight),
                            ],
                          ),
                          backgroundColor: ColorsManager.dark50,
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                        horizontalSpace(8),
                        Chip(
                          label: Row(
                            children: [
                              const MySvg(image: 'bed'),
                              horizontalSpace(8),
                              Text('${widget.property.roomCount ?? 0} غرف',
                                  style: TextStyles.font10Dark400Grey400Weight),
                            ],
                          ),
                          backgroundColor: ColorsManager.dark50,
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                        horizontalSpace(8),
                        Chip(
                          label: Row(
                            children: [
                              const MySvg(image: 'panio'),
                              horizontalSpace(8),
                              Text('${widget.property.bathroomCount ?? 0} حمام',
                                  style: TextStyles.font10Dark400Grey400Weight),
                            ],
                          ),
                          backgroundColor: ColorsManager.dark50,
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}