// lib/features/home/ui/widgets/home_list_view_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/router/routes.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_state.dart';
import '../../../../core/utils/helpers/spacing.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeListViewItem extends StatelessWidget {
  final HomeAdModel adModel;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  const HomeListViewItem({
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
    final favoriteType = 'ad';
    final favId = adModel.id;

    final created = DateTime.tryParse(adModel.createdAt);
    final createdAgo = created != null ? timeago.format(created, locale: 'ar') : '';

    return InkWell(
      onTap: () {
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
          default:
            Navigator.of(context).pushNamed(Routes.otherAdDetailsScreen, arguments: adModel.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.r),
        margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(adModel.title.isEmpty ? 'No Title' : adModel.title,
                      style: TextStyles.font12Black400Weight, maxLines: 2, overflow: TextOverflow.ellipsis),
                  verticalSpace(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          ListViewItemDataWidget(image: 'location-dark', text: adModel.location),
                          verticalSpace(8),
                          ListViewItemDataWidget(image: 'user', text: adModel.username),
                        ]),
                      ),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          ListViewItemDataWidget(
                            image: 'saudi_riyal',
                            isColoredText: true,
                            text: _formatPrice(context, adModel.price),
                          ),
                          verticalSpace(8),
                          ListViewItemDataWidget(image: 'clock', text: createdAgo),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            horizontalSpace(8),
            // الصورة + مفضلة فقط
            Stack(
              children: [
                SizedBox(
                  width: 102.w,
                  height: 90.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: hasImage
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Skeletonizer(enabled: true, child: Container(color: ColorsManager.grey200)),
                      errorWidget: (_, __, ___) => Container(color: ColorsManager.grey200, child: const Icon(Icons.error)),
                    )
                        : Container(color: ColorsManager.grey200, child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
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
                          padding: const EdgeInsets.all(2.0),
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
          ],
        ),
      ),
    );
  }

  String _formatPrice(BuildContext context, String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'N/A';
    String s = raw.trim();
    const arabic = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    const latin  = ['0','1','2','3','4','5','6','7','8','9'];
    for (int i = 0; i < arabic.length; i++) {
      s = s.replaceAll(arabic[i], latin[i]);
    }
    s = s.replaceAll('٬', '').replaceAll(',', '').replaceAll('٫', '.').replaceAll(RegExp(r'[^\d\.]'), '');
    final num? value = num.tryParse(s);
    if (value == null) return raw;

    final bool arDigits = Directionality.of(context) == TextDirection.RTL;
    final String locale = arDigits ? 'ar' : 'en';
    final format = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = (value % 1 == 0) ? 0 : 2;

    return format.format(value);
  }
}

