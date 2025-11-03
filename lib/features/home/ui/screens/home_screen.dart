import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/router/app_router.dart' show navigatorKey;
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import 'package:mushtary/features/home/ui/widgets/home_action_bar.dart';
import 'package:mushtary/features/home/ui/widgets/home_banners.dart';
import 'package:mushtary/features/home/ui/widgets/home_grid_view.dart';
import 'package:mushtary/features/home/ui/widgets/home_list_view.dart';
import 'package:mushtary/features/home/ui/widgets/home_screen_app_bar.dart';
import 'package:mushtary/features/home/ui/widgets/home_categories_list_view.dart';

import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/data/models/ads_filter.dart';

import 'package:mushtary/features/home/ui/widgets/home_filter/home_filter_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
import '../../../favorites/ui/logic/cubit/favorites_state.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';

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
          if (state is AddFavoriteFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsManager.redButton,
              ));
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
      case 'car_ads': return 1;
      case 'real_estate_ads': return 2;
      case 'car_parts_ads': return 3;
      case 'other_ads': return 4;
      default: return null;
    }
  }

  int _compareCreated(HomeAdModel a, HomeAdModel b) {
    final da = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
    final db = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
    return db.compareTo(da);
  }

  Future<void> _openSearch() async {
    navigatorKey.currentState?.pushNamed(Routes.searchScreen);
  }

  Future<void> _openFilter() async {
    final f = await showModalBottomSheet<AdsFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => HomeFilterSheet(
        initial: const AdsFilter(), // ممكن تمرر categoryId لو حابب
      ),
    );
    if (f != null) {
      navigatorKey.currentState?.pushNamed(
        Routes.filterResultsScreen,
        arguments: f,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
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

              final content = NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      toolbarHeight: 70.h,
                      flexibleSpace: HomeScreenAppBar(
                        onMenuTap: () => NavX(context).pushNamed(Routes.menuScreen),
                        onNotificationsTap: () => NavX(context).pushNamed(Routes.notificationsScreen),
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
                          NavX(context).pushNamed(Routes.reelsScreen, arguments: all);
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
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 100.h),
                      sliver: isListView
                          ? HomeListView(ads: displayedItems)
                          : HomeGridView(ads: displayedItems),
                    ),
                  ],
                ),
              );

              return Stack(
                children: [
                  content,
                  Positioned(
                    bottom: 16.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CircleAction( onTap: _openFilter, icon: 'filter_icon',),
                            SizedBox(width: 12.w),
                            _CircleAction(icon: 'search-normal', onTap: _openSearch),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
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
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
            SliverToBoxAdapter(child: verticalSpace(16.0)),
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarHeight: 60.h,
              flexibleSpace: const SizedBox(),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              sliver: SliverList.builder(
                itemCount: 6,
                itemBuilder: (_, __) => const SizedBox(height: 120),
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

class _CircleAction extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.secondary500.withOpacity(.8),
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: MySvg(image: icon,height: 18,width: 18,color: ColorsManager.primaryColor,)
        ),
      ),
    );
  }
}