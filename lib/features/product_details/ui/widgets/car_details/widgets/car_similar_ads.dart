// lib/features/car_details/ui/widgets/car_details/widgets/car_similar_ads.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../../../data/model/car_details_model.dart';

class CarSimilarAds extends StatelessWidget {
  final List<SimilarCarAdModel> similarAds;
  final void Function(SimilarCarAdModel ad)? onTapAd;

  const CarSimilarAds({
    super.key,
    required this.similarAds,
    this.onTapAd,
  });

  @override
  Widget build(BuildContext context) {
    if (similarAds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إعلانات مشابهة', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: similarAds.map((ad) => Padding(
                padding: EdgeInsets.only(right: 12.w, bottom: 16.h),
                child: _SimilarCarCard(ad: ad, onTap: () => onTapAd?.call(ad)),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarCarCard extends StatelessWidget {
  final SimilarCarAdModel ad;
  final VoidCallback? onTap;

  const _SimilarCarCard({required this.ad, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String? image = ad.image;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: SizedBox(
                height: 100.h,
                width: double.infinity,
                child: image != null && image.isNotEmpty
                    ? Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: MySvg(image: 'image')),
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                )
                    : const Center(child: MySvg(image: 'image')),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Text(
                    ad.price != null ? '${ad.price}' : '—',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.green[700], fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    ad.year?.toString() ?? '-',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
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