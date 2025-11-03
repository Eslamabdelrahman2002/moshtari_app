import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/router/routes.dart'; // ✅ UPDATED: استيراد Routes للـ navigation constants
import '../../data/model/exhibition_details_models.dart';
import '../logic/cubit/exhibition_details_cubit.dart';
import '../logic/cubit/exhibition_details_state.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart'; // ✅ UPDATED: للـ favorites toggle
import '../../../favorites/ui/logic/cubit/favorites_state.dart'; // ✅ UPDATED: للـ favorites state
import '../../../../core/utils/helpers/spacing.dart';

class ExhibitionDetailsScreen extends StatelessWidget {
  final int exhibitionId;
  const ExhibitionDetailsScreen({super.key, required this.exhibitionId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExhibitionDetailsCubit>(
          create: (_) => getIt<ExhibitionDetailsCubit>()..load(exhibitionId),
        ),
        BlocProvider<FavoritesCubit>( // ✅ UPDATED: أضف FavoritesCubit للـ toggle في _AdItemCard
          create: (_) => getIt<FavoritesCubit>()..fetchFavorites(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('الملف الشخصي', style: TextStyles.font20Black500Weight),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: ColorsManager.darkGray300),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<ExhibitionDetailsCubit, ExhibitionDetailsState>(
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator.adaptive());
            if (state.error != null) return Center(child: Text(state.error!));
            final data = state.data;
            if (data == null) return const Center(child: Text('لا توجد بيانات'));

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExhibitionHeaderCard(data: data),
                  verticalSpace(12),
                  SizedBox(
                    height: 46.h,
                    child: OutlinedButton(
                      onPressed: () {
                        // 💡 تحسين: نحدد المسار بناءً على نوع النشاط (activityType)
                        final String activityType = data.activityType;
                        String routeName = '';

                        if (activityType == 'real_estate_ad') {
                          routeName = Routes.createRealEstateAdFlow; // ✅ FIXED: استخدم الـ constant الصحيح
                        } else if (activityType == 'car_ad' || activityType == 'car_part_ad') {
                          routeName = Routes.createCarAdFlow; // ✅ FIXED: استخدم الـ constant الصحيح
                        }

                        if (routeName.isNotEmpty) {
                          Navigator.of(context).pushNamed(
                            routeName,
                            arguments: {
                              'exhibitionId': exhibitionId, // ✅ تمرير ID المعرض
                            },
                          );
                        } else {
                          // رسالة خطأ إذا كان نوع النشاط غير مدعوم
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('نوع النشاط غير مدعوم حالياً.')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorsManager.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'إضافة إعلان جديد',
                        style: TextStyle(
                          color: ColorsManager.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  verticalSpace(16),
                  Text('الإعلانات', style: TextStyles.font16Black500Weight),
                  verticalSpace(12),
                  if (data.ads.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(child: Text('لا توجد إعلانات بعد', style: TextStyles.font14Black500Weight)),
                    )
                  else
                    ListView.separated(
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemCount: data.ads.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) => _AdItemCard(
                        ad: data.ads[i],
                        activityType: data.activityType, // ✅ UPDATED: مرر activityType للـ _AdItemCard عشان يحدد الـ navigation (عربيات/عقارات)
                      ),
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

class ExhibitionHeaderCard extends StatelessWidget {
  final ExhibitionDetailsData data;
  const ExhibitionHeaderCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final timeText = _timeAgoAr(data.createdAt);

    return Container(
      height: 186.h,
      child: ClipRRect( // 🛠️ استخدام ClipRRect مع Stack للـ background image
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Background Image
            data.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: data.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              httpHeaders: const {
                'Connection': 'close',
                'User-Agent': 'Flutter/3.0 (Dart)',
              },
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: ColorsManager.darkGray300), // ✅ FIXED: شيل const من Icon
              ),
            )
                : Image.asset(
              'assets/images/Rectangle.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Overlay لزيادة التباين
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // محتوى الهيدر (وسط الكارد)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الصورة الدائرية في المنتصف مع إطار أبيض
                  Container(
                    padding: EdgeInsets.all(2.5.w),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: CircleAvatar(
                      radius: 26.r,
                      backgroundColor: Colors.white,
                      backgroundImage: (data.profilePictureUrl?.isNotEmpty == true)
                          ? CachedNetworkImageProvider(
                        data.profilePictureUrl!,
                        headers: const {
                          'Connection': 'close',
                          'User-Agent': 'Flutter/3.0 (Dart)',
                        },
                      )
                          : null,
                      child: (data.profilePictureUrl?.isNotEmpty ?? false)
                          ? null
                          : Icon(Icons.person, color: Colors.grey[600], size: 26.r),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // دائرة التوثيق الزرقاء + اسم المعرض
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _BlueVerifiedDot(),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          data.exhibitionName,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // التقييم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('(0) رأي', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                      SizedBox(width: 6.w),
                      Text('5.0', style: TextStyle(color: Colors.amber[400], fontWeight: FontWeight.w700)),
                      SizedBox(width: 4.w),
                      ...List.generate(5, (_) => Icon(Icons.star, size: 14.r, color: Colors.amber[400])),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // الصف السفلي: المدينة | منذ | عدد الإعلانات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place, size: 14.r, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(data.address, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                        ],
                      ),
                      _vDivider(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 14.r, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(timeText, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                        ],
                      ),
                      _vDivider(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.campaign_rounded, size: 14.r, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text('${data.adsCount} إعلان', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
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

  Widget _vDivider() => Container(margin: EdgeInsets.symmetric(horizontal: 10.w), width: 1.2, height: 14.h, color: Colors.white70);

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

class _BlueVerifiedDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Icon(Icons.check, color: Colors.white, size: 14.r),
    );
  }
}

// ✅ UPDATED: _AdItemCard محدث ليكون شبيه تماماً لـ HomeListViewItem (مع favorites، timeago، skeleton، navigation بس للعربيات والعقارات)
class _AdItemCard extends StatelessWidget {
  final ExhibitionAd ad;
  final String activityType; // ✅ UPDATED: parameter جديد لتحديد الـ navigation (من data.activityType)

  const _AdItemCard({
    required this.ad,
    required this.activityType, // ✅ UPDATED: مطلوب للـ navigation
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());

    final hasImage = (ad.imageUrls as List?)?.isNotEmpty ?? false; // ✅ FIXED: safe navigation للـ dynamic list
    final imageUrl = hasImage ? (ad.imageUrls as List).first.toString() : ''; // ✅ FIXED: cast و toString
    final favoriteType = 'ad'; // افتراضي للـ exhibition ads
    final favId = ad.hashCode; // ✅ FIXED: استخدم hashCode كـ fallback للـ id (أضف id للـ model لاحقاً)

    final nf = NumberFormat.decimalPattern('ar');
    final priceNum = ad.price as num?; // ✅ FIXED: cast للـ num
    final priceText = (priceNum != null && priceNum > 0) ? nf.format(priceNum) : '—'; // ✅ FIXED: safe check
    final adDateStr = ad.adDate?.toString() ?? ''; // ✅ FIXED: safe toString للـ date
    final created = DateTime.tryParse(adDateStr);
    final createdAgo = created != null ? timeago.format(created, locale: 'ar') : '';

    return InkWell(
      onTap: () {
        // ✅ UPDATED: Navigation بس للعربيات والعقارات بناءً على activityType (من الـ parent)
        if (activityType == 'car_ad' || activityType == 'car_part_ad') {
          Navigator.of(context).pushNamed(Routes.carDetailsScreen, arguments: favId); // ✅ FIXED: استخدم favId (hashCode)
        } else if (activityType == 'real_estate_ad') {
          Navigator.of(context).pushNamed(Routes.realEstateDetailsScreen, arguments: favId); // ✅ FIXED: استخدم favId
        } else {
          // Default لأي نوع تاني
          Navigator.of(context).pushNamed(Routes.otherAdDetailsScreen, arguments: favId);
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // الصورة
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: hasImage
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                httpHeaders: const {
                  // 🧱 خلى الـ Connection دايم شوية
                  'Connection': 'keep-alive',
                  'Keep-Alive': 'timeout=10, max=1000',
                  'User-Agent': 'Flutter/3.0 (Dart)',
                },
                width: 88.w,
                height: 72.h,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                // 🟢 Placeholder بسيط
                placeholder: (_, __) => Container(
                    color: ColorsManager.grey200,
                    child: const Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2))),
                // 🟡 ErrorWidget لو السيرفر قفل الاتصال
                errorWidget: (_, __, ___) => Container(
                  color: ColorsManager.grey200,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image, color: Colors.grey[500]),
                ),
              )
                  : Container(
                width: 88.w,
                height: 72.h,
                color: ColorsManager.grey200,
                child: Icon(Icons.image, color: Colors.grey[500], size: 32), // ✅ FIXED: شيل const
              ),
            ),
            SizedBox(width: 12.w),
            // النصوص + Favorites
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      ad.adTitle?.toString() ?? '', // ✅ FIXED: safe toString مع null check
                      style: TextStyles.font14Black500Weight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  SizedBox(height: 8.h),
                  Text(
                      '$priceText رس',
                      style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w700)
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.place, size: 14.r, color: ColorsManager.darkGray),
                      SizedBox(width: 4.w),
                      Text('—', style: TextStyles.font12DarkGray400Weight), // لا يوجد اسم مدينة في الاستجابة
                      SizedBox(width: 8.w),
                      Icon(Icons.access_time, size: 14.r, color: ColorsManager.darkGray),
                      SizedBox(width: 4.w),
                      Text(createdAgo, style: TextStyles.font12DarkGray400Weight),
                    ],
                  ),
                ],
              ),
            ),
            // Favorites Toggle (مشابه للـ HomeListViewItem)
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                bool isFav = false; // افتراضي (يمكن تمرير isFavorited من الـ parent)
                if (state is FavoritesLoaded) {
                  isFav = state.favoriteIds.contains(favId);
                }
                return GestureDetector(
                  onTap: () => context.read<FavoritesCubit>().toggleFavorite(type: favoriteType, id: favId),
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: MySvg(
                      image: "favourite",
                      width: 20,
                      height: 20,
                      color: isFav ? ColorsManager.redButton : Colors.grey[500],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}