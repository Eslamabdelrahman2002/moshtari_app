import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

class AdCardData {
  final int id;
  final String title;
  final String? imageUrl;
  final String location;     // الرياض
  final String ownerName;    // اسم المستخدم
  final String price;        // نص سعر جاهز للعرض
  final String timeAgo;      // مثل "منذ ساعة"

  final VoidCallback? onTap;

  const AdCardData({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.ownerName,
    required this.price,
    required this.timeAgo,
    this.onTap,
  });
}

class AdListCard extends StatelessWidget {
  final AdCardData data;
  const AdListCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
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
                    child: (data.imageUrl?.isNotEmpty == true)
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
                  verticalSpace(12),

                  // سطر: المدينة يمين
                  Row(
                    children: [
                      Expanded(child: Container()), // ترك فراغ يسار (زي الفيجما)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MySvg(image: 'location-dark', width: 12, height: 12, color: ColorsManager.darkGray300),
                          horizontalSpace(6),
                          Text(data.location, style: TextStyles.font12DarkGray400Weight, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                  verticalSpace(8),

                  // سطر سفلي: السعر (أصفر) يسار - الوقت يمين
                  Row(
                    children: [
                      // يسار: السعر
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MySvg(image: 'saudi_riyal', width: 12, height: 12, color: ColorsManager.success500?? Colors.amber),
                            horizontalSpace(6),
                            Text(
                              data.price,
                              style: TextStyles.font10Yellow500Weight ??
                                  TextStyle(color: ColorsManager.success500 ?? Colors.amber, fontSize: 12.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      // يمين: الوقت + اسم المستخدم
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MySvg(image: 'clock', width: 12, height: 12, color: ColorsManager.darkGray300),
                          horizontalSpace(6),
                          Text(data.timeAgo, style: TextStyles.font12DarkGray400Weight),
                          horizontalSpace(12),
                          MySvg(image: 'user', width: 12, height: 12, color: ColorsManager.darkGray300),
                          horizontalSpace(6),
                          Text(data.ownerName, style: TextStyles.font12DarkGray400Weight, overflow: TextOverflow.ellipsis),
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
}