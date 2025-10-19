import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// تم حذف الاستيرادات الخاصة بـ share_plus و flutter_cache_manager
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:share_plus/share_plus.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CarDetailsImages extends StatefulWidget {
  final List<String> images;
  final String? status; // مستخدمة / جديدة (اختياريّة لعرض التاج فقط)

  // معلومات المشاركة (يمكن إبقاءها كـ Data Properties أو حذفها)
  final String? adTitle;
  final String? adPrice;
  final String? shareUrl;
  final String? shareLocation;
  final String? createdAt;

  // 💡 الإضافة: دالة استدعاء للنقر على زر المشاركة
  final VoidCallback? onShareTap;

  const CarDetailsImages({
    super.key,
    required this.images,
    this.status,
    this.adTitle,
    this.adPrice,
    this.shareUrl,
    this.shareLocation,
    this.createdAt,
    this.onShareTap, // 💡 تم إضافة الكولباك
  });

  @override
  State<CarDetailsImages> createState() => _CarDetailsImagesState();
}

class _CarDetailsImagesState extends State<CarDetailsImages> {
  final PageController controller = PageController();
  int index = 0;

  bool get _hasImages => widget.images.isNotEmpty;

  // ❌ تم حذف دالة _formatCreatedAt و _shareAd

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285.h,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: PageView.builder(
              controller: controller,
              itemCount: _hasImages ? widget.images.length : 1,
              onPageChanged: (i) => setState(() => index = i),
              itemBuilder: (_, i) {
                if (!_hasImages) {
                  return Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const MySvg(image: 'image'),
                  );
                }
                return CachedNetworkImage(
                  imageUrl: widget.images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (_, __, ___) => const Center(child: MySvg(image: 'image')),
                );
              },
            ),
          ),

          // أعلى-يسار: حالة الإعلان (اختياري)
          if ((widget.status ?? '').isNotEmpty)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ColorsManager.primary100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(widget.status!, style: TextStyles.font12Primary400400Weight),
              ),
            ),

          // أعلى-يمين: زر مشاركة
          Positioned(
            top: 12.h,
            left: 12.w,
            child: _circleIcon(
              child: const MySvg(image: 'share', color: ColorsManager.white),
              onTap: widget.onShareTap, // 💡 تم ربط النقر بالكولباك الممرر
            ),
          ),


        ],
      ),
    );
  }

  Widget _circleIcon({required Widget child, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}