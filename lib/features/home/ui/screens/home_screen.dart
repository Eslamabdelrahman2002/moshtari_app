import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/home/ui/widgets/home_action_bar.dart';
import 'package:mushtary/features/home/ui/widgets/home_banners.dart';
import 'package:mushtary/features/home/ui/widgets/home_grid_view.dart';
import 'package:mushtary/features/home/ui/widgets/home_list_view.dart';
import 'package:mushtary/features/home/ui/widgets/home_screen_app_bar.dart';
import 'package:mushtary/features/home/ui/widgets/home_categories_list_view.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_state.dart';
import '../../data/models/home_data_model.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HomeCubit>()..fetchHomeData()),
        BlocProvider(create: (_) => getIt<FavoritesCubit>()..fetchFavorites()),
      ],
      child: BlocListener<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          // عرض رسالة الخطأ فقط
          if (state is AddFavoriteFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ColorsManager.redButton,
                ),
              );
          }
        },
        child: const HomeView(),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  bool isListView = false;
  String? _selectedCategoryKey;
  bool _showAuctions = false;

  int? _selectedCategoryId() {
    switch (_selectedCategoryKey) {
      case 'car_ads':
        return 1;
      case 'real_estate_ads':
        return 2;
      case 'car_parts_ads':
        return 3;
      case 'other_ads':
        return 4;
      default:
        return null;
    }
  }

  int _compareCreated(HomeAdModel a, HomeAdModel b) {
    final da = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
    final db = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
    return db.compareTo(da);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              // استخدم Skeletonizer بدلاً من الـ CircularProgressIndicator
              return _buildLoadingSkeleton(context);
            }
            if (state is HomeFailure) {
              return Center(child: Text(state.error));
            }
            if (state is HomeSuccess) {
              final homeData = state.homeData;

              List<HomeAdModel> displayedItems;
              final catId = _selectedCategoryId();

              if (_showAuctions) {
                final allAuctionsAsAds = homeData.auctions.map(HomeAdModel.fromAuction).toList();
                displayedItems = (catId == null)
                    ? allAuctionsAsAds
                    : allAuctionsAsAds.where((ad) => ad.categoryId == catId).toList();
              } else {
                if (catId == null) {
                  displayedItems = [
                    ...homeData.carAds,
                    ...homeData.realEstateAds,
                    ...homeData.carPartsAds,
                    ...homeData.otherAds,
                  ]..sort(_compareCreated);
                } else {
                  displayedItems = homeData.adsByCategory(catId)..sort(_compareCreated);
                }
              }

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      toolbarHeight: 70.h,
                      flexibleSpace: HomeScreenAppBar(
                        onMenuTap: () => context.pushNamed(Routes.menuScreen),
                        onNotificationsTap: () => context.pushNamed(Routes.notificationsScreen),
                      ),
                    ),
                    SliverToBoxAdapter(child: verticalSpace(16.0)),
                    const SliverToBoxAdapter(child: HomeBanners()),
                    SliverToBoxAdapter(child: verticalSpace(16.0)),
                    SliverToBoxAdapter(
                      child: HomeCategoriesListView(
                        categoriesToShow: _showAuctions
                            ? const {'car_ads': 'سيارات', 'real_estate_ads': 'عقارات'}
                            : const {
                          'car_ads': 'سيارات',
                          'real_estate_ads': 'عقارات',
                          'car_parts_ads': 'قطع غيار',
                          'other_ads': 'أخرى'
                        },
                        selectedCategoryKey: _selectedCategoryKey,
                        onCategorySelected: (key) => setState(() => _selectedCategoryKey = key),
                      ),
                    ),
                    SliverToBoxAdapter(child: verticalSpace(16.0)),
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      toolbarHeight: 60.h,
                      flexibleSpace: HomeActionBar(
                        onGridViewTap: () => setState(() => isListView = false),
                        onListViewTap: () => setState(() => isListView = true),
                        onReelsViewTap: () {
                          final all = [
                            ...homeData.carAds,
                            ...homeData.realEstateAds,
                            ...homeData.carPartsAds,
                            ...homeData.otherAds,
                          ]..sort(_compareCreated);
                          context.pushNamed(Routes.reelsScreen, arguments: all);
                        },
                        isListView: isListView,
                        isAuctionsView: _showAuctions,
                        onAuctionsViewChanged: (value) {
                          setState(() {
                            _showAuctions = value;
                            _selectedCategoryKey = null;
                          });
                        },
                      ),
                    ),
                  ];
                },
                body: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(0, 16.h, 0, 0),
                      sliver: isListView
                          ? HomeListView(ads: displayedItems)
                          : HomeGridView(ads: displayedItems),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    // صفحة Skeleton أثناء التحميل
    return Skeletonizer(
      enabled: true,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              toolbarHeight: 70.h,
              flexibleSpace: HomeScreenAppBar(
                onMenuTap: () {},
                onNotificationsTap: () {},
              ),
            ),
            SliverToBoxAdapter(child: verticalSpace(16.0)),
            // Banners skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16.r,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: verticalSpace(16.0)),
            // Categories skeleton
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  separatorBuilder: (_, __) => horizontalSpace(8),
                  itemBuilder: (_, __) => Container(
                    width: 80.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8.r,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: verticalSpace(16.0)),
            // Action bar skeleton
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarHeight: 60.h,
              flexibleSpace: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12.r,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              sliver: isListView
                  ? SliverList.builder(
                itemCount: 6,
                itemBuilder: (_, __) => _ListItemSkeleton(),
              )
                  : SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                      (_, __) => _GridItemSkeleton(),
                  childCount: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _GridItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16.r,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(color: ColorsManager.grey200),
            ),
          ),
          verticalSpace(8),
          // عنوان
          Container(height: 12.h, width: double.infinity, color: ColorsManager.grey200),
          verticalSpace(8),
          // صفين من البيانات
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(height: 10.h, color: ColorsManager.grey200),
                    verticalSpace(4),
                    Container(height: 10.h, width: 80.w, color: ColorsManager.grey200),
                  ],
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: Column(
                  children: [
                    Container(height: 10.h, color: ColorsManager.grey200),
                    verticalSpace(4),
                    Container(height: 10.h, width: 60.w, color: ColorsManager.grey200),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12.h, width: 180.w, color: ColorsManager.grey200),
                verticalSpace(16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(height: 10.h, color: ColorsManager.grey200),
                          verticalSpace(8),
                          Container(height: 10.h, width: 80.w, color: ColorsManager.grey200),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(height: 10.h, color: ColorsManager.grey200),
                          verticalSpace(8),
                          Container(height: 10.h, width: 60.w, color: ColorsManager.grey200),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          horizontalSpace(8),
          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 102.w,
              height: 90.h,
              color: ColorsManager.grey200,
            ),
          ),
        ],
      ),
    );
  }
}