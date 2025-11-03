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
import '../../../product_details/ui/widgets/share_dialog.dart';
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

  // ✅ دالة لعمل رابط المشاركة بناءً على نوع الإعلان
  String _buildShareLink(HomeAdModel ad) {
    final isAuction = ad.auctionDisplayType != null;
    final id = isAuction ? (ad.auctionId ?? ad.id) : ad.id;
    final type = isAuction ? 'auction' : 'ad';
    return 'https://moshtary.com/$type/$id';
  }

  // ✅ دالة التنقل للتفاصيل
  void _navigateToAdDetails(BuildContext context, HomeAdModel ad) {
    final isAuction = ad.auctionDisplayType != null;
    final auctionId = ad.auctionId ?? ad.id;

    if (isAuction) {
      if (ad.categoryId == 1) {
        Navigator.of(context).pushNamed(
          Routes.carAuctionDetailsScreen,
          arguments: auctionId,
        );
      } else if (ad.categoryId == 2) {
        Navigator.of(context).pushNamed(
          Routes.realEstateAuctionDetailsScreen,
          arguments: auctionId,
        );
      }
      return;
    }

    switch (ad.sourceType) {
      case 'car_ads':
        Navigator.of(context)
            .pushNamed(Routes.carDetailsScreen, arguments: ad.id);
        break;
      case 'real_estate_ads':
        Navigator.of(context)
            .pushNamed(Routes.realEstateDetailsScreen, arguments: ad.id);
        break;
      case 'car_parts_ads':
      case 'car_part_ads':
        Navigator.of(context)
            .pushNamed(Routes.carPartDetailsScreen, arguments: ad.id);
        break;
      case 'other_ads':
      default:
        Navigator.of(context)
            .pushNamed(Routes.otherAdDetailsScreen, arguments: ad.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Scaffold(
        backgroundColor: ColorsManager.blackBackground,
        body: SafeArea(
          child: Skeletonizer(
            enabled: true,
            child: PageView.builder(
              itemCount: 3,
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
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification &&
              notification.scrollDelta != null &&
              notification.metrics.axis == Axis.vertical) {
            _onScrollStarted();
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
            final shareLink = _buildShareLink(ad);

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
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    width: 32.w,
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      color:
                                      ColorsManager.white.withOpacity(0.5),
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    child: const PrimaryBackIcon(
                                      color: ColorsManager.white,
                                    ),
                                  ),
                                ),
                                // ✅ شعار التطبيق، ممكن نضيف زر المشاركة هنا مستقبلاً
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'عرض الإعلان',
                          isPrefixIconInCenter: true,
                          prefixIcon: const MySvg(image: 'eye_white'),
                          onPressed: () => _navigateToAdDetails(context, ad),
                        ),
                      ),
                    ],
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
            Positioned.fill(
              child: Container(color: Colors.white),
            ),
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
                  Container(width: 140.w, height: 24.h, color: Colors.white),
                  SizedBox(width: 32.w, height: 32.h),
                ],
              ),
            ),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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