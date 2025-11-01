import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../user_profile/data/model/my_ads_model.dart';
import '../../../user_profile/data/model/my_auctions_model.dart';

class PublisherProductItem extends StatelessWidget {
  final Object model; // MyAdsModel أو MyAuctionModel
  const PublisherProductItem({super.key, required this.model});

  // ---------------- Helpers ----------------
  String _fmtNum(num v) =>
      v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},');

  String _fmtPrice(String? s) {
    if (s == null || s.isEmpty) return '';
    final n = num.tryParse(s.replaceAll(',', ''));
    return n == null ? s : _fmtNum(n);
  }

  String _timeAgo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    DateTime? dt;
    try {
      dt = DateTime.parse(iso).toLocal();
    } catch (_) {}
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return '${diff.inHours} ساعة';
    return '${diff.inDays} يوم';
  }

  String _categoryLabel(Object m) {
    if (m is MyAuctionModel) {
      switch (m.typeAuctions) {
        case 'car':
          return 'مزاد سيارات';
        case 'real_estate':
          return 'مزاد عقارات';
        default:
          return 'مزاد';
      }
    } else if (m is MyAdsModel) {
      const map = {
        5: 'سيارات',
        1: 'سيارات',
        2: 'قطع غيار',
        3: 'عقارات',
        4: 'أخرى',
      };
      return map[m.categoryId] ?? 'إعلان';
    }
    return '';
  }

  IconData _categoryIcon(Object m) {
    final label = _categoryLabel(m);
    if (label.contains('سيارات')) return Icons.directions_car_filled;
    if (label.contains('عقارات')) return Icons.home_work_rounded;
    if (label.contains('قطع')) return Icons.build_rounded;
    return Icons.category_rounded;
  }

  // ------------------------------------------------------
  void _openDetails(BuildContext context) {
    // 🔹 إعلانات عادية
    if (model is MyAdsModel) {
      final m = model as MyAdsModel;
      final id = m.id;

      switch (m.categoryId) {
        case 1:
        case 5:
          Navigator.of(context)
              .pushNamed(Routes.carDetailsScreen, arguments: id);
          break;
        case 2:
          Navigator.of(context)
              .pushNamed(Routes.carPartDetailsScreen, arguments: id);
          break;
        case 3:
          Navigator.of(context)
              .pushNamed(Routes.realEstateDetailsScreen, arguments: id);
          break;
        case 4:
        default:
          Navigator.of(context)
              .pushNamed(Routes.otherAdDetailsScreen, arguments: id);
      }
    }

    // 🔹 مزادات الناشر
    else if (model is MyAuctionModel) {
      final m = model as MyAuctionModel;
      final id = m.id;

      // ✅ نعتمد فقط على typeAuctions (car أو real_estate)
      if (m.typeAuctions == 'real_estate') {
        Navigator.of(context).pushNamed(
          Routes.realEstateAuctionDetailsScreen,
          arguments: id,
        );
      } else {
        Navigator.of(context).pushNamed(
          Routes.carAuctionDetailsScreen,
          arguments: id,
        );
      }
    }
  }

  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isAuction = model is MyAuctionModel;
    final category = _categoryLabel(model);
    final categoryIcon = _categoryIcon(model);

    String title = '';
    String createdAt = '';
    String priceText = '';
    String? imageUrl;

    if (model is MyAdsModel) {
      final m = model as MyAdsModel;
      title = m.title;
      createdAt = m.createdAt;
      priceText = _fmtPrice(m.price);
      imageUrl =
      m.imageUrls.isNotEmpty ? m.imageUrls.first : null;
    } else if (model is MyAuctionModel) {
      final m = model as MyAuctionModel;
      title = m.title;
      createdAt = m.createdAt;
      priceText = _fmtPrice(m.startingPrice);
      imageUrl =
      m.thumbnail.isNotEmpty ? m.thumbnail : null;
    }

    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 11 / 9,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported))
                        : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator.adaptive()),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    left: 8.w,
                    top: 8.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: ColorsManager.secondary50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: ColorsManager.secondary200),
                      ),
                      child: Row(
                        children: [
                          Icon(categoryIcon,
                              size: 14, color: ColorsManager.secondary600),
                          horizontalSpace(4),
                          Text(category,
                              style: TextStyles.font10Yellow400Weight),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.h, right: 10.w, left: 10.w),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.font14Black500Weight,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 10.h),
              child: Row(
                children: [
                  Row(
                    children: [
                      MySvg(image: 'clock', width: 14.w, height: 14.w),
                      horizontalSpace(4),
                      Text(_timeAgo(createdAt),
                          style: TextStyles.font10Dark600Grey400Weight),
                    ],
                  ),
                  const Spacer(),
                  if (!isAuction)
                    Row(
                      children: [
                        Text('﷼ ',
                            style: TextStyles.font10Secondary500700Weight),
                        Text(priceText,
                            style: TextStyles.font10Secondary500700Weight),
                      ],
                    )
                  else
                    SizedBox(
                      height: 34.h,
                      child: OutlinedButton(
                        onPressed: () => _openDetails(context),
                        style: OutlinedButton.styleFrom(
                          padding:
                          EdgeInsets.symmetric(horizontal: 12.w),
                          side: BorderSide(
                              color: ColorsManager.primary200),
                          foregroundColor: ColorsManager.primary400,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('عرض التفاصيل',
                            style: TextStyles.font12Blue400Weight),
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