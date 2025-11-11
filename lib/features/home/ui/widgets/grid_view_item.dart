// lib/features/home/ui/widgets/grid_view_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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

    // مزاد: نوع، حالة، أعلى مزايدة، عدد المزايدات، هل المستخدم زايد
    final dispTypeLabel = (adModel.auctionDisplayType == 'single') ? 'فردي' : (adModel.auctionDisplayType == 'multiple' ? 'متعدد' : null);
    final _status = _readAuctionStatus(adModel); // live/ongoing/ended
    final bool ended = _status == _AuctionStatus.ended;
    final bool liveOrOngoing = _status == _AuctionStatus.live || _status == _AuctionStatus.ongoing;

    final String highestBidText = _formatPrice(context,
      _readHighestBid(adModel) ?? adModel.price,
    );

    final int bidsCount = _readBidsCount(adModel) ?? 0;
    final bool userHasBid = _readUserHasBid(adModel) ?? false;

    return InkWell(
      onTap: () {
        if (isAuction) {
          if (adModel.categoryId == 1) {
            Navigator.of(context).pushNamed(Routes.carAuctionDetailsScreen, arguments: adModel.auctionId ?? adModel.id);
          } else if (adModel.categoryId == 2) {
            Navigator.of(context).pushNamed(Routes.realEstateAuctionDetailsScreen, arguments: adModel.auctionId ?? adModel.id);
          } else {
            Navigator.of(context).pushNamed(Routes.otherAdDetailsScreen, arguments: adModel.id);
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
            // صورة + ترويسة المزاد + شريط أعلى مزايدة
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

                  if (isAuction) ...[
                    // ترويسة المزاد (أعلى الصورة يسار): مزاد حي/جار/منتهي + فردي/متعدد
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Row(
                        children: [
                          if (dispTypeLabel != null)
                            _pill(dispTypeLabel, ColorsManager.success500),
                          if (dispTypeLabel != null) horizontalSpace(4),
                          _pill(
                            ended ? 'منتهي' : (_status == _AuctionStatus.live ? 'مزاد حي' : 'جار'),
                            ended ? ColorsManager.darkGray300 : ColorsManager.redButton,
                            icon: ended ? Icons.timer_off : Icons.wifi_tethering, // أيقونة تقريبية
                          ),
                        ],
                      ),
                    ),
                    // شريط “أعلى مزايدة” أسفل الصورة (مثل الفيجما)
                    Positioned(
                      left: 8.w,
                      right: 8.w,
                      bottom: 8.h,
                      child: _highestBidBar(context, highestBidText),
                    ),
                  ],

                  // زر المفضلة
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
            // العنوان
            Text(
              adModel.title.isEmpty ? 'No Title' : adModel.title,
              style: TextStyles.font12Black400Weight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpace(8),

            // سطرين: (الموقع/المستخدم) + (السعر/الوقت) + حالة "تمت المزايدة/لم تتم"
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
                      image: 'saudi_riyal',
                      width: 10,
                      height: 10,
                      isColoredText: true,
                      text: _formatPrice(context, adModel.price),
                    ),
                    verticalSpace(4),
                    ListViewItemDataWidget(image: 'clock', text: createdAgo),
                  ]),
                ),
              ],
            ),
            if (isAuction) ...[
              verticalSpace(6),
              Row(
                children: [
                  Expanded(
                    child: ListViewItemDataWidget(
                      image: 'auction', // أيقونة “مزاد” إن وُجدت
                      text: '$bidsCount مزايدة',
                    ),
                  ),
                  _pill(
                    userHasBid ? 'تمّت المزايدة' : 'لم تتم المزايدة',
                    userHasBid ? ColorsManager.success500 : ColorsManager.darkGray300,
                    small: true,
                    icon: userHasBid ? Icons.check_circle : Icons.radio_button_unchecked,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // شريط أعلى مزايدة (يشبه الفيجما)
  Widget _highestBidBar(BuildContext context, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          MySvg(image: 'saudi_riyal', width: 12, height: 12, color: Colors.white),
          horizontalSpace(6),
          Expanded(
            child: Text(
              value,
              style: TextStyles.font12White400Weight.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          horizontalSpace(8),
          Text('أعلى مزايدة:', style: TextStyles.font10White500Weight.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  // شارة صغيرة (Tag/Pill)
  Widget _pill(String text, Color color, {bool small = false, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6.w : 8.w, vertical: small ? 2.h : 4.h),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 10.sp : 12.sp, color: Colors.white),
            horizontalSpace(4),
          ],
          Text(text, style: TextStyles.font10White500Weight.copyWith(fontSize: small ? 8.sp : 10.sp)),
        ],
      ),
    );
  }

  // Helpers to read optional auction fields safely
  _AuctionStatus _readAuctionStatus(HomeAdModel m) {
    String? status;
    DateTime? endsAt;
    try { status = (m as dynamic).auctionStatus as String?; } catch (_) {}
    try { endsAt = DateTime.tryParse(((m as dynamic).endsAt as String?) ?? ((m as dynamic).auctionEndAt as String?) ?? ''); } catch (_) {}

    status = status?.toLowerCase();
    if (status == 'ended' || status == 'finished' || status == 'closed') return _AuctionStatus.ended;
    if (status == 'live') return _AuctionStatus.live;
    if (status == 'ongoing' || status == 'running') return _AuctionStatus.ongoing;

    if (endsAt != null) {
      return endsAt.isBefore(DateTime.now()) ? _AuctionStatus.ended : _AuctionStatus.ongoing;
    }
    return _AuctionStatus.ongoing; // افتراضي
  }

  String? _readHighestBid(HomeAdModel m) {
    dynamic v;
    try { v = (m as dynamic).highestBid; } catch (_) {}
    v ??= m.price; // fallback
    return v?.toString();
  }

  int? _readBidsCount(HomeAdModel m) {
    try { return (m as dynamic).bidsCount as int?; } catch (_) {}
    try { return (m as dynamic).bids_count as int?; } catch (_) {}
    return null;
  }

  bool? _readUserHasBid(HomeAdModel m) {
    try { return (m as dynamic).userHasBid as bool?; } catch (_) {}
    try { return (m as dynamic).didUserBid as bool?; } catch (_) {}
    return null;
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

enum _AuctionStatus { live, ongoing, ended }