import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

// Cubits
import 'package:mushtary/features/user_profile_id/ui/cubit/user_ads_cubit.dart';
import 'package:mushtary/features/user_profile_id/ui/cubit/user_auctions_cubit.dart';
import 'package:mushtary/features/user_profile_id/ui/cubit/user_reviews_cubit.dart';

// Models & Widgets
import '../../../user_profile_id/data/model/my_ads_model.dart';
import '../../../user_profile_id/data/model/my_auctions_model.dart';
import '../../../user_profile_id/ui/widgets/reviews_tab_view.dart';
import '../../../user_profile_id/ui/widgets/publisher_product_item.dart'; // ← الودجت الجديدة

class UserProfileScreenId extends StatefulWidget {
  const UserProfileScreenId({super.key});

  @override
  State<UserProfileScreenId> createState() => _UserProfileScreenIdState();
}

class _UserProfileScreenIdState extends State<UserProfileScreenId> {
  late final UserReviewsCubit _userReviewsCubit;
  late final UserAdsCubit _userAdsCubit;
  late final UserAuctionsCubit _userAuctionsCubit;

  int? _userId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _userReviewsCubit = getIt<UserReviewsCubit>();
    _userAdsCubit = getIt<UserAdsCubit>();
    _userAuctionsCubit = getIt<UserAuctionsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ استقبال الـ userId أول مرة فقط
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _userId = args is int ? args : int.tryParse(args.toString());
      if (_userId != null) {
        _userReviewsCubit.fetchUserReviews(_userId!);
        _userAdsCubit.fetchUserAds(_userId!);
        _userAuctionsCubit.fetchUserAuctions(_userId!);
      }
      _initialized = true;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _userReviewsCubit),
        BlocProvider.value(value: _userAdsCubit),
        BlocProvider.value(value: _userAuctionsCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('الملف الشخصي', style: TextStyles.font20Black500Weight),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: MySvg(image: "chat", height: 24.w, color: ColorsManager.primary500),
            ),
            horizontalSpace(8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<UserReviewsCubit, UserReviewsState>(
                builder: (context, state) {
                  if (state is UserReviewsLoading) {
                    return const Center(child: CircularProgressIndicator.adaptive());
                  }

                  if (state is UserReviewsSuccess) {
                    final userData = state.userData;
                    final averageRating = userData['average_rating'] ?? '0.00';
                    final reviewsCount = userData['review_count'] ?? '0';
                    final promoter =
                    (userData['promoter'] is Map<String, dynamic>)
                        ? userData['promoter'] as Map<String, dynamic>
                        : null;
                    final provider =
                    (userData['provider'] is Map<String, dynamic>)
                        ? userData['provider'] as Map<String, dynamic>
                        : null;

                    final isVerified = (promoter?['status'] == 'approved' ||
                        provider?['status'] == 'approved');

                    final cityNameAr =
                        (promoter?['city_name_ar'] ?? provider?['city_name_ar']) ??
                            'غير محدد';
                    final profilePicture = userData['profile_picture_url'];
                    final username = userData['username'];
                    final email = userData['email'];
                    final phone = userData['phone_number'];

                    return Column(
                      children: [
                        _buildProfileCard(
                          username: username,
                          email: email,
                          phone: phone,
                          profilePictureUrl: profilePicture,
                          city: cityNameAr,
                          averageRating:
                          double.tryParse(averageRating.toString()) ?? 0.0,
                          reviewsCount:
                          int.tryParse(reviewsCount.toString()) ?? 0,
                          isVerified: isVerified,
                        ),
                        verticalSpace(16),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                _buildTabBar(),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      // 🔹 تبويب الإعلانات والمزادات
                                      BlocBuilder<UserAdsCubit, UserAdsState>(
                                        builder: (context, adsState) {
                                          return BlocBuilder<UserAuctionsCubit,
                                              UserAuctionsState>(
                                            builder:
                                                (context, auctionsState) {
                                              if (adsState
                                              is UserAdsLoading ||
                                                  auctionsState
                                                  is UserAuctionsLoading) {
                                                return const Center(
                                                    child:
                                                    CircularProgressIndicator.adaptive());
                                              }

                                              if (adsState is UserAdsFailure) {
                                                return Center(
                                                  child: Text(
                                                    'فشل تحميل الإعلانات: ${adsState.error}',
                                                    style: TextStyles
                                                        .font14Red500Weight,
                                                  ),
                                                );
                                              }

                                              if (auctionsState
                                              is UserAuctionsFailure) {
                                                return Center(
                                                  child: Text(
                                                    'فشل تحميل المزادات: ${auctionsState.error}',
                                                    style: TextStyles
                                                        .font14Red500Weight,
                                                  ),
                                                );
                                              }

                                              final myAds =
                                              (adsState is UserAdsSuccess)
                                                  ? List<
                                                  MyAdsModel>.from(
                                                  adsState.ads)
                                                  : <MyAdsModel>[];

                                              final myAuctions =
                                              (auctionsState
                                              is UserAuctionsSuccess)
                                                  ? List<
                                                  MyAuctionModel>.from(
                                                  auctionsState
                                                      .auctions)
                                                  : <MyAuctionModel>[];

                                              if (myAds.isEmpty &&
                                                  myAuctions.isEmpty) {
                                                return Center(
                                                  child: Text(
                                                    'لا توجد إعلانات أو مزادات حالياً.',
                                                    style: TextStyles
                                                        .font16Dark300Grey400Weight,
                                                  ),
                                                );
                                              }

                                              return SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .stretch,
                                                  children: [
                                                    // إعلانات الناشر
                                                    if (myAds.isNotEmpty)
                                                      Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            12.w),
                                                        child: GridView
                                                            .builder(
                                                          shrinkWrap: true,

                                                          physics:
                                                          const NeverScrollableScrollPhysics(),
                                                          gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2,
                                                            crossAxisSpacing: 12,
                                                            mainAxisSpacing: 12,
                                                            childAspectRatio: 0.78,
                                                          ),
                                                          itemCount:
                                                          myAds.length,
                                                          itemBuilder: (context,
                                                              index) =>
                                                              PublisherProductItem(
                                                                  model: myAds[
                                                                  index]),
                                                        ),
                                                      ),

                                                    // مزادات الناشر
                                                    if (myAuctions.isNotEmpty)
                                                      Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            12.w),
                                                        child: GridView
                                                            .builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                          const NeverScrollableScrollPhysics(),
                                                          gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2,
                                                            crossAxisSpacing:
                                                            12,
                                                            mainAxisSpacing:
                                                            12,
                                                            childAspectRatio:
                                                            0.78,
                                                          ),
                                                          itemCount:
                                                          myAuctions.length,
                                                          itemBuilder:
                                                              (context,
                                                              index) =>
                                                              PublisherProductItem(
                                                                  model: myAuctions[
                                                                  index]),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),

                                      // 🔹 تبويب التقييمات
                                      const ReviewsTabView(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is UserReviewsFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64.r,
                              color: ColorsManager.redButton),
                          verticalSpace(16),
                          Text(
                            'فشل تحميل البيانات: ${state.error}',
                            style: TextStyles.font14Red500Weight,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // كارت الملف الشخصي (بدون تعديل)
  // -------------------------------------------------------------
  Widget _buildProfileCard({
    required String? username,
    required String? email,
    required String? phone,
    required String? profilePictureUrl,
    required String city,
    required double averageRating,
    required int reviewsCount,
    required bool isVerified,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.w,
            backgroundColor: ColorsManager.lightGrey,
            backgroundImage: profilePictureUrl != null
                ? CachedNetworkImageProvider(profilePictureUrl)
                : null,
            child: profilePictureUrl == null
                ? MySvg(
              image: "profile",
              height: 50.w,
              color: ColorsManager.primary400,
            )
                : null,
          ),
          verticalSpace(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(username ?? 'لا يوجد اسم',
                  style: TextStyles.font18Black500Weight),
              horizontalSpace(6),
              if (isVerified)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Row(
                    children: [
                      Icon(Icons.verified,
                          size: 14.r, color: Colors.green),
                      horizontalSpace(4),
                      Text('موثّق',
                          style: TextStyles.font12Green400Weight),
                    ],
                  ),
                ),
            ],
          ),
          verticalSpace(4),
          Text(email ?? '', style: TextStyles.font12DarkGray400Weight),
          Text(phone ?? '', style: TextStyles.font12DarkGray400Weight),
          verticalSpace(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(city, style: TextStyles.font12DarkGray400Weight),
              horizontalSpace(8),
              const Icon(Icons.star,
                  color: Colors.amber, size: 16),
              horizontalSpace(4),
              Text('${averageRating.toStringAsFixed(1)}',
                  style: TextStyles.font12Blue400Weight),
              horizontalSpace(4),
              Text('($reviewsCount تقييم)',
                  style: TextStyles.font12DarkGray400Weight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 42.h,
      margin:
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: TabBar(
        labelColor: ColorsManager.primary500,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyles.font14Dark500Weight,
        indicatorColor: ColorsManager.primary500,
        tabs: const [
          Tab(text: 'الإعلانات والمزادات'),
          Tab(text: 'التقييمات'),
        ],
      ),
    );
  }
}