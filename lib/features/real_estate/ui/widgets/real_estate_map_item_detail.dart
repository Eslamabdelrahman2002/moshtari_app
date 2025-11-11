// lib/features/real_estate/ui/widgets/real_estate_map_item_detail.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';
import '../../data/model/real_estate_ad_model.dart';

class RealEstateMapItemDetails extends StatelessWidget {
  final RealEstateListModel? listing;
  final VoidCallback? onClose; // ✅ لإغلاق البطاقة
  final VoidCallback? onTap; // ✅ للانتقال للتفاصيل

  const RealEstateMapItemDetails({
    super.key,
    this.listing,
    this.onClose,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (listing == null) {
      return Container(
        height: 106.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text('اضغط على marker لعرض التفاصيل'),
        ),
      );
    }

    // ✅ تغليف المحتوى بـ GestureDetector لتفعيل الضغط للانتقال
    return GestureDetector(
      onTap: onTap,
      child: Stack( // ✅ استخدام Stack لوضع زر الإغلاق الدائري
        children: [
          Container(
            height: 106.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing!.title ?? 'عقار غير محدد',
                      style: TextStyles.font14Black500Weight,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListViewItemDataWidget(
                              image: 'location-dark',
                              text: listing!.cityName ?? 'غير محدد',
                              width: 12.w,
                              height: 12.h,
                            ),
                            verticalSpace(4),
                            ListViewItemDataWidget(
                              image: 'user',
                              text: listing!.username ?? 'مستخدم',
                              width: 12.w,
                              height: 12.h,
                            ),
                          ],
                        ),
                        horizontalSpace(36),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListViewItemDataWidget(
                              image: 'saudi_riyal',
                              isColoredText: true,
                              text: listing!.price ?? 'غير محدد',
                              width: 12.w,
                              height: 12.h,
                            ),
                            verticalSpace(4),
                            ListViewItemDataWidget(
                              image: 'clock',
                              text: _formatTimeAgo(listing!.createdAt),
                              width: 12.w,
                              height: 12.h,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsManager.dark50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              const MySvg(image: 'ruler'),
                              horizontalSpace(4),
                              Text(
                                '${listing!.roomCount ?? 0} غرف',
                                style: TextStyles.font10Dark400Grey400Weight,
                              ),
                            ],
                          ),
                        ),
                        horizontalSpace(16),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsManager.dark50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              const MySvg(image: 'bed'),
                              horizontalSpace(4),
                              Text(
                                '${listing!.roomCount ?? 0} غرفة',
                                style: TextStyles.font10Dark400Grey400Weight,
                              ),
                            ],
                          ),
                        ),
                        horizontalSpace(16),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsManager.dark50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              const MySvg(image: 'panio'),
                              horizontalSpace(4),
                              Text(
                                '${listing!.bathroomCount ?? 0} حمام',
                                style: TextStyles.font10Dark400Grey400Weight,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    imageUrl: listing!.imageUrls?.isNotEmpty == true
                        ? listing!.imageUrls!.first
                        : 'https://via.placeholder.com/102x90',
                    fit: BoxFit.cover,
                    width: 102.w,
                    height: 90.h,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                  ),
                ),
              ],
            ),
          ),
          // ✅ زر الإغلاق الدائري الأصفر
          if (onClose != null)
            Positioned(
              top: -8.h,
              left: -8.w,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16.w, color: ColorsManager.darkGray300),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'غير محدد';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return '${diff.inHours} ساعة';
    return '${diff.inDays} يوم';
  }
}