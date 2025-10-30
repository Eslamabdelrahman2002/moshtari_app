import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

// مهم: استخدم موديل العقارات بالـ alias
import 'package:mushtary/features/real_estate_details/date/model/real_estate_details_model.dart' as re;

class RealEstateSimilarAds extends StatelessWidget {
  final List<re.SimilarAd> items;
  final void Function(re.SimilarAd ad)? onTapAd;

  const RealEstateSimilarAds({
    super.key,
    required this.items,
    this.onTapAd,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إعلانات مشابهة', style: Theme.of(context).textTheme.titleMedium),
          verticalSpace(12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((ad) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w, bottom: 16.h),
                  child: _SimilarAdCard(
                    ad: ad,
                    onTap: () => onTapAd?.call(ad),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarAdCard extends StatelessWidget {
  final re.SimilarAd ad;
  final VoidCallback? onTap;

  const _SimilarAdCard({required this.ad, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String? image = ad.imageUrls.isNotEmpty ? ad.imageUrls.first : null;

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
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: SizedBox(
                height: 100.h,
                width: double.infinity,
                child: image != null && image.isNotEmpty
                    ? Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  verticalSpace(4),
                  Text(
                    ad.price != null ? '${ad.price}' : '—',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  verticalSpace(2),
                  Text(
                    ad.realEstateType,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: const Center(
      child: Icon(Icons.home_outlined, color: Colors.grey),
    ),
  );
}