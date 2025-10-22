import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import '../../../../core/utils/helpers/spacing.dart';
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
      padding: EdgeInsets.all(16.w), // زيادة Padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)), // ظل أعمق
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28.r, // زيادة حجم الصورة
                backgroundColor: ColorsManager.lightGrey,
                backgroundImage: (provider.personalImage?.isNotEmpty ?? false)
                    ? CachedNetworkImageProvider(provider.personalImage!)
                    : null,
                child: (provider.personalImage?.isNotEmpty ?? false) ? null : Icon(Icons.person, color: Colors.grey, size: 30.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(provider.fullName,
                              style: TextStyles.font18Black500Weight, // خط أكبر
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        // شارة موثق يمكن إضافتها هنا
                        // if (provider.isVerified) _VerifiedBadge(),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text('${provider.rating.average.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ColorsManager.secondary500)),
                        SizedBox(width: 4.w),
                        Icon(Icons.star, size: 16.r, color: ColorsManager.secondary500),
                        SizedBox(width: 8.w),
                        Text('(${provider.reviewsCount} رأي)',
                            style: TextStyles.font12DarkGray400Weight),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              // Badge نوع الخدمة
              if ((provider.serviceType ?? '').isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ColorsManager.primary50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: ColorsManager.primary200),
                  ),
                  child: Text(provider.serviceType!,
                      style: TextStyles.font14Primary300500Weight),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          // الإحصائيات في الأسفل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(title: 'المدينة', value: provider.cityName ?? '-', icon: Icons.location_on_rounded),
              _Dot(),
              _Stat(title: 'عدد الأعمال', value: '$jobsCount', icon: Icons.business_center_rounded),
              _Dot(),
              _Stat(title: 'التفضيلات', value: '$favoritesCount', icon: Icons.favorite_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  const _Stat({required this.title, required this.value, this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 16.r, color: ColorsManager.darkGray300),
              if (icon != null) horizontalSpace(4),
              Text(title, style: TextStyles.font12DarkGray400Weight),
            ],
          ),
          SizedBox(height: 4.h),
          Text(value, style: TextStyles.font16Black500Weight), // خط أكبر للقيم
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 6.r, height: 6.r, decoration: const BoxDecoration(color: Color(0xFFE1E1E1), shape: BoxShape.circle));
  }
}