import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/work_with_us/data/model/promoter_profile_models.dart';


class ExhibitionCard extends StatelessWidget {
  final Exhibition exhibition;
  final VoidCallback? onQuickAd;

  const ExhibitionCard({
    super.key,
    required this.exhibition,
    this.onQuickAd,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = _timeAgoAr(exhibition.createdAt);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              exhibition.imageUrl,
              width: 88.w,
              height: 88.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 88.w,
                height: 88.w,
                color: ColorsManager.primary50,
                child: Icon(Icons.image, color: ColorsManager.darkGray),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exhibition.name, style: TextStyles.font14Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.r, color: ColorsManager.darkGray),
                    SizedBox(width: 4.w),
                    Text(dateText, style: TextStyles.font12DarkGray400Weight),
                    SizedBox(width: 8.w),
                    Icon(Icons.place, size: 14.r, color: ColorsManager.darkGray),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(exhibition.address, style: TextStyles.font12DarkGray400Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.campaign_rounded, size: 14.r, color: ColorsManager.darkGray),
                    SizedBox(width: 4.w),
                    Text('${exhibition.adCount} إعلان', style: TextStyles.font12DarkGray400Weight),
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 36.h,
                  child: OutlinedButton(
                    onPressed: onQuickAd,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorsManager.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('إضافة إعلان سريع', style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgoAr(DateTime? dt) {
    if (dt == null) return 'منذ —';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays >= 365) {
      final y = (diff.inDays / 365).floor();
      return 'منذ $y سنة';
    } else if (diff.inDays >= 30) {
      final m = (diff.inDays / 30).floor();
      return 'منذ $m شهر';
    } else if (diff.inDays >= 1) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours >= 1) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes >= 1) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}