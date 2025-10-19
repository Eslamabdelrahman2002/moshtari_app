import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/work_with_us/data/model/promoter_profile_models.dart';


class ProfileHeaderCard extends StatelessWidget {
  final Profile profile;
  final int countAccounts;
  final int? totalEarnings; // اختياري لو أضيف لاحقاً من API

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.countAccounts,
    this.totalEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // الصورة
              CircleAvatar(
                radius: 26.r,
                backgroundColor: ColorsManager.primary50,
                backgroundImage: (profile.profileImageUrl?.isNotEmpty == true)
                    ? NetworkImage(profile.profileImageUrl!)
                    : null,
                child: (profile.profileImageUrl?.isNotEmpty ?? false)
                    ? null
                    : Icon(Icons.person, color: ColorsManager.darkGray, size: 26.r),
              ),
              SizedBox(width: 12.w),
              // الاسم + شارة موثّق + تقييم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(profile.username.isEmpty ? 'اسم المستخدم' : profile.username,
                            style: TextStyles.font16Black500Weight),
                        _VerifiedBadge(),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[600], size: 16.r),
                        SizedBox(width: 4.w),
                        Text('5.0', style: TextStyles.font12DarkGray400Weight),
                        SizedBox(width: 4.w),
                        Text('(0 رأي)', style: TextStyles.font12DarkGray400Weight),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // الإحصائيات: المدينة - عدد الحسابات - الأرباح
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatTile(title: 'المدينة', value: profile.cityNameAr.isEmpty ? '-' : profile.cityNameAr),
              _DividerDot(),
              _StatTile(title: 'عدد الحسابات', value: '$countAccounts'),
              _DividerDot(),
              _StatTile(title: 'الأرباح', value: totalEarnings != null ? '+${totalEarnings} رس' : '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FFF3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF18C37D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14.r, color: const Color(0xFF18C37D)),
          SizedBox(width: 4.w),
          Text('موثّق', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF18C37D), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  const _StatTile({required this.title, required this.value});

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

class _DividerDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.r,
      height: 6.r,
      decoration: const BoxDecoration(color: Color(0xFFE1E1E1), shape: BoxShape.circle),
    );
  }
}