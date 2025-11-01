import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../data/model/exhibition_details_models.dart';
import '../logic/cubit/exhibition_details_cubit.dart';
import '../logic/cubit/exhibition_details_state.dart';

class ExhibitionDetailsScreen extends StatelessWidget {
  final int exhibitionId;
  const ExhibitionDetailsScreen({super.key, required this.exhibitionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExhibitionDetailsCubit>(
      create: (_) => getIt<ExhibitionDetailsCubit>()..load(exhibitionId),
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
                        // TODO: إضافة إعلان جديد
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
                      itemBuilder: (_, i) => _AdItemCard(ad: data.ads[i]),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage( // Always include DecorationImage
          image: data.imageUrl.isNotEmpty
              ? CachedNetworkImageProvider(
            data.imageUrl,
            headers: const {'Connection': 'close'},
          ) as ImageProvider // Cast to ImageProvider
              : const AssetImage(
            'assets/images/Rectangle.png', // Fallback to the provided local asset
          ),
          fit: BoxFit.cover,
        ),
        // Removed direct color: Colors.grey[300] since DecorationImage handles the background now.
      ),
      child: Stack(
        children: [
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
                      headers: const {'Connection': 'close'},
                    ) as ImageProvider // Cast to ImageProvider
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

class _AdItemCard extends StatelessWidget {
  final ExhibitionAd ad;
  const _AdItemCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.decimalPattern('ar');
    final priceText = ad.price > 0 ? nf.format(ad.price) : '—';
    final timeText = _timeAgoAr(ad.adDate);
    final thumb = ad.imageUrls.isNotEmpty ? ad.imageUrls.first : null;

    final cacheW = (88.w * MediaQuery.of(context).devicePixelRatio).round();
    final cacheH = (72.w * MediaQuery.of(context).devicePixelRatio).round();

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: thumb != null
                ? CachedNetworkImage(
              imageUrl: thumb,
              httpHeaders: const {'Connection': 'close'},
              width: 88.w,
              height: 72.w,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              memCacheWidth: cacheW,
              memCacheHeight: cacheH,
              placeholder: (_, __) => Container(width: 88.w, height: 72.w, color: Colors.grey[200]),
              errorWidget: (_, __, ___) =>
                  Container(width: 88.w, height: 72.w, color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey[500])),
            )
                : Container(width: 88.w, height: 72.w, color: Colors.grey[200], child: Icon(Icons.image, color: Colors.grey[500])),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad.adTitle, style: TextStyles.font14Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Text('$priceText رس', style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w700)),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.place, size: 14.r, color: ColorsManager.darkGray),
                    SizedBox(width: 4.w),
                    Text('—', style: TextStyles.font12DarkGray400Weight), // لا يوجد اسم مدينة في الاستجابة
                    SizedBox(width: 8.w),
                    Icon(Icons.access_time, size: 14.r, color: ColorsManager.darkGray),
                    SizedBox(width: 4.w),
                    Text(timeText, style: TextStyles.font12DarkGray400Weight),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.favorite_border, color: Colors.grey[500]),
        ],
      ),
    );
  }

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