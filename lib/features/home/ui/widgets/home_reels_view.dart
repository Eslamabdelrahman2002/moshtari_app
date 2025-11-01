import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_back_icon.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/full_view_content_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../user_profile/logic/cubit/profile_cubit.dart';
import '../../data/models/home_data_model.dart';

class HomeReelsView extends StatefulWidget {
  final List<HomeAdModel> ads;
  final bool isLoading;

  const HomeReelsView({
    super.key,
    required this.ads,
    this.isLoading = false,
  });

  @override
  State<HomeReelsView> createState() => _HomeReelsViewState();
}

class _HomeReelsViewState extends State<HomeReelsView> {
  bool _isScrolling = false;

  void _onScrollStarted() {
    if (!_isScrolling) {
      setState(() => _isScrolling = true);
    }
  }

  void _onScrollStopped() {
    if (_isScrolling) {
      setState(() => _isScrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // وضع التحميل: استخدم Skeletonizer بدل CircularProgressIndicator.adaptive
    if (widget.isLoading) {
      return Scaffold(
        backgroundColor: ColorsManager.blackBackground,
        body: SafeArea(
          child: Skeletonizer(
            enabled: true,
            child: PageView.builder(
              itemCount: 3, // عدد سلايدات السكيليتون
              scrollDirection: Axis.vertical,
              itemBuilder: (context, i) => const _ReelSkeletonSlide(),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: ColorsManager.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset.zero,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Skeletonizer(
            enabled: true,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      );
    }

    // أثناء العرض الحقيقي: نوفر Cubits لتفادي ProviderNotFoundException
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesCubit>(
          create: (context) => getIt<FavoritesCubit>()..fetchFavorites(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => getIt<ProfileCubit>()..loadProfile(),
        ),
      ],
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.scrollDelta != null &&
                notification.metrics.axis == Axis.vertical) {
              _onScrollStarted();
            }
          } else if (notification is ScrollEndNotification) {
            _onScrollStopped();
          }
          return true;
        },
        child: PageView.builder(
          itemCount: widget.ads.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, i) {
            final ad = widget.ads[i];
            return Scaffold(
              backgroundColor: ColorsManager.blackBackground,
              body: SafeArea(
                child: Stack(
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ad.imageUrls?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(ad.imageUrls?[index] ?? ''),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedOpacity(
                      opacity: _isScrolling ? 0 : 1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FullViewContentWidget(adModel: ad),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _isScrolling ? 0 : 1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    width: 32.w,
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      color: ColorsManager.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: const PrimaryBackIcon(
                                      color: ColorsManager.white,
                                    ),
                                  ),
                                ),
                                const MySvg(image: 'logo'),
                                const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          verticalSpace(24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: AnimatedOpacity(
                opacity: _isScrolling ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorsManager.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: PrimaryButton(
                    text: 'عرض الاعلان',
                    isPrefixIconInCenter: true,
                    prefixIcon: const MySvg(image: 'eye_white'),
                    onPressed: () {
                      NavX(context).pushNamed(
                        Routes.productDetails,
                        arguments: ad,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReelSkeletonSlide extends StatelessWidget {
  const _ReelSkeletonSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.blackBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // الخلفية (مكان الصورة/الفيديو)
            Positioned.fill(
              child: Container(
                color: Colors.white, // سيُظلل بواسطة Skeletonizer
              ),
            ),

            // ترويسة أعلى الشاشة
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  Container(
                    width: 140.w,
                    height: 24.h,
                    color: Colors.white,
                  ),
                  SizedBox(width: 32.w, height: 32.h),
                ],
              ),
            ),

            // أزرار الجانب الأيمن (مفضلة/تعليقات/مشاركة)
            Positioned(
              right: 12.w,
              bottom: 120.h,
              child: Column(
                children: [
                  _circleSkeleton(40.r),
                  SizedBox(height: 16.h),
                  _circleSkeleton(40.r),
                  SizedBox(height: 16.h),
                  _circleSkeleton(40.r),
                ],
              ),
            ),

            // المحتوى السفلي (عنوان/سعر/موقع/مستخدم...)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsManager.blackBackground,
                      ColorsManager.blackBackground.withOpacity(0.65),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // النصوص
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // شارة السعر
                          Container(
                            height: 36.h,
                            width: 160.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // العنوان سطرين
                          Container(height: 16.h, width: 260.w, color: Colors.white),
                          SizedBox(height: 8.h),
                          Container(height: 16.h, width: 200.w, color: Colors.white),
                          SizedBox(height: 16.h),
                          // منذ وقت
                          Container(height: 12.h, width: 100.w, color: Colors.white),
                          SizedBox(height: 16.h),
                          // معلومات المستخدم
                          Row(
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 12.h, width: 140.w, color: Colors.white),
                                    SizedBox(height: 6.h),
                                    Container(height: 12.h, width: 100.w, color: Colors.white),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          // الموقع + السعر
                          Row(
                            children: [
                              Container(height: 16.h, width: 120.w, color: Colors.white),
                              SizedBox(width: 16.w),
                              Container(height: 16.h, width: 100.w, color: Colors.white),
                            ],
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                    SizedBox(width: 60.w), // مساحة للأزرار الجانبية
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _circleSkeleton(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}
