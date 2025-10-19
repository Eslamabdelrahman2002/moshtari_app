// [Path to your FavoritesCubit]
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_back_icon.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/product_details/ui/widgets/full_view_widget/full_view_content_widget.dart';

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
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // *** الحل لـ ProviderNotFoundException: إنشاء Cubits هنا باستخدام getIt ***
    return MultiBlocProvider(
      providers: [
        // 1. توفير FavoritesCubit
        BlocProvider<FavoritesCubit>(
          create: (context) => getIt<FavoritesCubit>()..fetchFavorites(),
        ),
        // 2. توفير ProfileCubit وحل المشكلة
        BlocProvider<ProfileCubit>(
          // ننشئه مباشرة هنا لضمان توفره. يجب أن يقوم .loadProfile بملء البيانات
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
                              image: NetworkImage(
                                ad.imageUrls?[index] ?? '',
                              ),
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
                        // FullViewContentWidget الآن يمكنها الوصول لـ FavoritesCubit و ProfileCubit
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
                                const MySvg(image: 'white_logo_with_name'),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: PrimaryButton(
                    text: 'عرض الاعلان',
                    isPrefixIconInCenter: true,
                    prefixIcon: const MySvg(image: 'eye_white'),
                    onPressed: () {
                      context.pushNamed(
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