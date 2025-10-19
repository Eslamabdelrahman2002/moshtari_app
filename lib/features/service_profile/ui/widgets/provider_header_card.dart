import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import '../../data/model/service_provider_models.dart';




class ProviderHeaderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final int favoritesCount;
  final int jobsCount;

  const ProviderHeaderCard({
    super.key,
    required this.provider,
    required this.favoritesCount,
    required this.jobsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: (provider.personalImage?.isNotEmpty ?? false)
                    ? CachedNetworkImageProvider(provider.personalImage!)
                    : null,
                child: (provider.personalImage?.isNotEmpty ?? false) ? null : const Icon(Icons.person, color: Colors.grey),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(provider.fullName,
                              style: TextStyles.font16Black500Weight,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        // SizedBox(width: 6.w),
                        // _VerifiedBadge(),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text('${provider.rating.average.toStringAsFixed(1)}',
                            style: TextStyles.font12DarkGray400Weight),
                        SizedBox(width: 4.w),
                        Icon(Icons.star, size: 14.r, color: Colors.amber[600]),
                        SizedBox(width: 6.w),
                        Text('(${provider.reviewsCount} رأي)',
                            style: TextStyles.font12DarkGray400Weight),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              if ((provider.serviceType ?? '').isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ColorsManager.primary50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: ColorsManager.primary200),
                  ),
                  child: Text(provider.serviceType!,
                      style: TextStyles.font12Primary300400Weight),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(title: 'المدينة', value: provider.cityName ?? '-'),
              _Dot(),
              _Stat(title: 'عدد الأعمال', value: '$jobsCount'),
              _Dot(),
              _Stat(title: 'التفضيلات', value: '$favoritesCount'),
            ],
          ),
        ],
      ),
    );
  }
}

// class _VerifiedBadge extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: ColorsManager.lightGreen,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.verified, size: 14.r, color: ColorsManager.success500),
//           SizedBox(width: 4.w),
//           Text('موثّق', style: TextStyle(fontSize: 12.sp, color: ColorsManager.success500, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }

class _Stat extends StatelessWidget {
  final String title;
  final String value;
  const _Stat({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyles.font12DarkGray400Weight),
        SizedBox(height: 4.h),
        Text(value, style: TextStyles.font14Black500Weight),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 6.r, height: 6.r, decoration: const BoxDecoration(color: Color(0xFFE1E1E1), shape: BoxShape.circle));
  }
}