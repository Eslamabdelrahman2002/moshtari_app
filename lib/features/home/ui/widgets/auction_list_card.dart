import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

// بيانات جاهزة للكارت (تقدر تبنيها من موديلاتك)
class AuctionCardData {
  final int id;
  final String title;
  final String? imageUrl;
  final String ownerName;
  final int categoryId;            // 1 سيارات - 2 عقارات - غيره: أخرى
  final bool isMultiple;           // true => متعدد, false => فردي
  final AuctionStatus status;      // ended / live / ongoing
  final int? lotsCount;            // (24 سيارة)
  final num? highestBid;           // أعلى مزايدة (اختياري)
  final bool showHighestBidBadge;  // لو عايز تظهر البادج الأزرق "أعلى مزايدة"
  final String? city;              // مدينة (اختياري)

  AuctionCardData({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ownerName,
    required this.categoryId,
    required this.isMultiple,
    required this.status,
    this.lotsCount,
    this.highestBid,
    this.showHighestBidBadge = false,
    this.city,
  });
}

enum AuctionStatus { ended, live, ongoing }

class AuctionListCard extends StatelessWidget {
  final AuctionCardData data;
  final VoidCallback? onTap;

  const AuctionListCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ribbonText = 'مزاد ${data.isMultiple ? 'متعدد' : 'فردي'}';
    final ribbonColor = data.status == AuctionStatus.ended
        ? ColorsManager.redButton
        : data.status == AuctionStatus.live
        ? ColorsManager.redButton
        : ColorsManager.success500; // جارٍ => أخضر

    final categoryLabel = _categoryLabel(data.categoryId);
    final lotsText = (data.isMultiple && (data.lotsCount ?? 0) > 0)
        ? '(${_pluralCars(data.lotsCount!)} )'
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة يسار + جرس
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: Container(
                    width: 88.w,
                    height: 88.w,
                    color: ColorsManager.grey200,
                    child: (data.imageUrl != null && data.imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                      imageUrl: data.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: ColorsManager.grey200, child: const Icon(Icons.error)),
                    )
                        : Icon(Icons.image_not_supported, color: Colors.grey[400]),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.notifications_active, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),

            horizontalSpace(12.w),

            // المحتوى يمين
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    data.title.isEmpty ? 'بدون عنوان' : data.title,
                    style: TextStyles.font14Black500Weight ??
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpace(8),

                  // سطر الميتا: يسار (سيارات + (24 سيارة)) ويمين شارة مزاد
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // يسار
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _metaWithIcon(
                              svg: 'drive', // لو عندك svg لعجلة القيادة
                              fallbackIcon: Icons.directions_car,
                              text: categoryLabel,
                              color: ColorsManager.success500 ?? Colors.amber,
                            ),
                            if (lotsText != null)
                              Text(
                                lotsText,
                                style: TextStyles.font14Red500Weight ??
                                    TextStyle(color: ColorsManager.redButton, fontSize: 12.sp, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      ),
                      // يمين: الشارة المتراصة
                      _stackedAuctionRibbon(text: ribbonText, color: ribbonColor),
                    ],
                  ),
                  verticalSpace(8),

                  // لو عايز تظهر أعلى مزايدة (زي الصورة الثانية)
                  if (data.showHighestBidBadge && (data.highestBid != null)) ...[
                    _highestBidBadge(_formatPrice(data.highestBid!)),
                    verticalSpace(8),
                  ],

                  // سطر الحالة: يسار (منتهي/مزاد حي/جار) ويمين اسم المستخدم أو المدينة
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              data.status == AuctionStatus.ended
                                  ? Icons.timer_off
                                  : Icons.access_time,
                              size: 16,
                              color: data.status == AuctionStatus.ended
                                  ? ColorsManager.redButton
                                  : ColorsManager.success500 ?? Colors.amber,
                            ),
                            horizontalSpace(6),
                            Text(
                              data.status == AuctionStatus.ended
                                  ? 'منتهي'
                                  : (data.status == AuctionStatus.live ? 'مزاد حي' : 'جار'),
                              style: TextStyle(
                                color: data.status == AuctionStatus.ended
                                    ? ColorsManager.redButton
                                    : ColorsManager.success500 ?? Colors.amber,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MySvg(image: 'user', width: 12, height: 12, color: ColorsManager.darkGray300),
                          horizontalSpace(6),
                          Text(
                            // لو تحب تعرض مدينة بدلاً من اسم المستخدم:
                            (data.city != null && data.city!.isNotEmpty) ? data.city! : data.ownerName,
                            style: TextStyles.font12DarkGray400Weight,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // badge أزرق "أعلى مزايدة"
  Widget _highestBidBadge(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3F51F3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة ريال على خلفية دائرية
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: MySvg(image: 'saudi_riyal', width: 14, height: 14, color: Colors.white),
          ),
          horizontalSpace(8),
          Text(
            value,
            style: TextStyles.font12White400Weight ??
                TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          horizontalSpace(8),
          Row(
            children: [
              MySvg(image: 'auction_up', width: 12, height: 12, color: Colors.white), // لو عندك svg
              horizontalSpace(4),
              Text('أعلى مزايدة', style: TextStyles.font10White500Weight ?? TextStyle(fontSize: 10.sp, color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }

  // شارة مزاد “كروت متراصة”
  Widget _stackedAuctionRibbon({required String text, required Color color}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(right: -6, top: 6, child: _ribbonLayer(color.withOpacity(0.55))),
        Positioned(right: -3, top: 3, child: _ribbonLayer(color.withOpacity(0.75))),
        _ribbonMain(text: text, color: color),
      ],
    );
  }

  Widget _ribbonLayer(Color c) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12.r)),
      child: const SizedBox(width: 64, height: 12),
    );
  }

  Widget _ribbonMain({required String text, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gavel, size: 14, color: Colors.white),
          horizontalSpace(6),
          Text(text, style: TextStyles.font12White400Weight ?? const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _metaWithIcon({
    String? svg,
    required IconData fallbackIcon,
    required String text,
    Color? color,
  }) {
    final iconColor = color ?? ColorsManager.darkGray300;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        svg != null
            ? MySvg(image: svg, width: 14, height: 14, color: iconColor)
            : Icon(fallbackIcon, size: 14, color: iconColor),
        horizontalSpace(4),
        Text(text, style: TextStyles.font12DarkGray400Weight),
      ],
    );
  }

  String _formatPrice(num value) {
    final f = NumberFormat.decimalPattern('ar');
    return f.format(value);
  }

  String _categoryLabel(int? id) {
    if (id == 1) return 'سيارات';
    if (id == 2) return 'عقارات';
    return 'أخرى';
  }

  String _pluralCars(int count) {
    // أبسط صيغة كما بالتصميم
    return '$count سيارة';
  }
}