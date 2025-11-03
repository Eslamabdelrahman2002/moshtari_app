// lib/features/work_with_us/ui/screens/work_with_us_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

// Profile (promoter)
import 'package:mushtary/features/work_with_us/data/model/promoter_profile_models.dart';
import 'package:mushtary/features/work_with_us/ui/logic/cubit/promoter_profile_cubit.dart';
import 'package:mushtary/features/work_with_us/ui/logic/cubit/promoter_profile_state.dart';

// Exhibitions list
import 'package:mushtary/features/work_with_us/data/model/exhibitions_list_models.dart';
import 'package:mushtary/features/work_with_us/ui/logic/cubit/exhibitions_cubit.dart';
import 'package:mushtary/features/work_with_us/ui/logic/cubit/exhibitions_state.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../widgets/create_exhibition_dialog.dart';
import 'exhibition_details_screen.dart';

class WorkWithUsProfileScreen extends StatelessWidget {
  const WorkWithUsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PromoterProfileCubit>(
          create: (_) => getIt<PromoterProfileCubit>()..loadProfile(),
        ),
        BlocProvider<ExhibitionsCubit>(
          create: (_) => getIt<ExhibitionsCubit>()..load(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('أعمل معنا', style: TextStyles.font20Black500Weight),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<PromoterProfileCubit, PromoterProfileState>(
          builder: (context, pState) {
            if (pState.loading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (pState.error != null) {
              return Center(child: Text(pState.error!));
            }

            final PromoterProfileResponse? data = pState.data;
            if (data == null) {
              return const Center(child: Text('لا توجد بيانات'));
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(
                    profile: data.data.profile,
                    countAccounts: data.data.countAccount,
                    totalEarnings: 350,
                  ),
                  verticalSpace(12),
                  SizedBox(
                    height: 46.h,
                    child: OutlinedButton(
                      onPressed: () async {
                        final ok = await showCreateExhibitionDialog(context);
                        if (ok == true && context.mounted) {
                          context.read<ExhibitionsCubit>().load();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side:
                        BorderSide(color: ColorsManager.primaryColor, width: 1.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          color: ColorsManager.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  verticalSpace(16),
                  Text('الحسابات المضافة',
                      style: TextStyles.font16Black500Weight),
                  verticalSpace(12),
                  BlocBuilder<ExhibitionsCubit, ExhibitionsState>(
                    builder: (context, eState) {
                      if (eState.loading) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                      if (eState.error != null) {
                        return Center(child: Text(eState.error!));
                      }
                      if (eState.items.isEmpty) {
                        return const Center(
                            child: Text('لا توجد حسابات/معارض مضافة حالياً'));
                      }
                      return ListView.separated(
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemCount: eState.items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) =>
                            _ExhibitionCardV2(ex: eState.items[i]),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: ColorsManager.lightGreen,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('موثّق',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorsManager.success500,
                  fontWeight: FontWeight.w600)),
          SizedBox(width: 4.w),
          Icon(Icons.verified,
              size: 14.r, color: ColorsManager.success500),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final bool hasLocationIcon;
  final bool isEarnings;

  const _StatTile({
    required this.title,
    required this.value,
    this.hasLocationIcon = false,
    this.isEarnings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasLocationIcon) ...[
                Icon(Icons.place, size: 16.r, color: ColorsManager.darkGray),
                SizedBox(width: 4.w),
              ],
              Text(title, style: TextStyles.font12DarkGray400Weight),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: isEarnings
                ? TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.success500,
                fontWeight: FontWeight.w700)
                : TextStyles.font14Black500Weight,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1.w, height: 40.h, color: Colors.grey[300]);
  }
}

class _HeaderCard extends StatelessWidget {
  final Profile profile;
  final int countAccounts;
  final int? totalEarnings;

  const _HeaderCard({
    required this.profile,
    required this.countAccounts,
    this.totalEarnings,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatar;
    if ((profile.profileImageUrl?.isNotEmpty ?? false)) {
      avatar = NetworkImage(profile.profileImageUrl!);
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: ColorsManager.primary50,
                backgroundImage: avatar,
                child: avatar == null
                    ? Icon(Icons.person,
                    color: ColorsManager.darkGray, size: 26.r)
                    : null,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        profile.username.isEmpty
                            ? 'اسم المستخدم'
                            : profile.username,
                        style: TextStyles.font16Black500Weight,
                      ),
                      SizedBox(width: 8.w),
                      _VerifiedBadge(),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('5.0',
                          style: TextStyles.font14Black500Weight
                              .copyWith(color: Colors.amber[600])),
                      SizedBox(width: 4.w),
                      Icon(Icons.star, color: Colors.amber[600], size: 16.r),
                      SizedBox(width: 4.w),
                      Text('(5 آراء)',
                          style: TextStyles.font12DarkGray400Weight),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatTile(
                title: 'المدينة',
                value:
                profile.cityNameAr.isEmpty ? '-' : profile.cityNameAr,
                hasLocationIcon: true,
              ),
              _StatDivider(),
              _StatTile(title: 'عدد الحسابات', value: '$countAccounts'),
              _StatDivider(),
              _StatTile(
                title: 'الأرباح',
                value: totalEarnings != null
                    ? '+${totalEarnings} رس'
                    : '—',
                isEarnings: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExhibitionCardV2 extends StatelessWidget {
  final ExhibitionItem ex;
  const _ExhibitionCardV2({required this.ex});

  @override
  Widget build(BuildContext context) {
    final timeText = _timeAgoAr(ex.createdAt);
    final adCount = ex.adCount;

    final cacheW =
    (100.w * MediaQuery.of(context).devicePixelRatio).round();
    final cacheH =
    (120.w * MediaQuery.of(context).devicePixelRatio).round();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ExhibitionDetailsScreen(exhibitionId: ex.id)),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                ex.imageUrl,
                width: 100.w,
                height: 120.w,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                cacheWidth: cacheW,
                cacheHeight: cacheH,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 100.w,
                    height: 120.w,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.transparent,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
                      strokeWidth: 2.2,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 100.w,
                  height: 120.w,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.name,
                    style: TextStyles.font14Black500Weight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            size: 14.r, color: ColorsManager.darkGray),
                        SizedBox(width: 4.w),
                        Text(timeText,
                            style: TextStyles.font12DarkGray400Weight),
                      ],
                    ),
                    _tinyDot(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place,
                            size: 14.r, color: ColorsManager.darkGray),
                        SizedBox(width: 4.w),
                        Text(ex.address,
                            style: TextStyles.font12DarkGray400Weight,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    _tinyDot(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign_rounded,
                            size: 14.r, color: ColorsManager.darkGray),
                        SizedBox(width: 4.w),
                        Text('$adCount إعلان',
                            style: TextStyles.font12DarkGray400Weight),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tinyDot() => Container(
    width: 4.r,
    height: 4.r,
    decoration:
    BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
  );

  String _timeAgoAr(DateTime? dt) {
    if (dt == null) return 'الآن';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays >= 365) return 'منذ ${(diff.inDays / 365).floor()} سنة';
    if (diff.inDays >= 30) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    if (diff.inDays >= 1) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours >= 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes >= 1) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }
}