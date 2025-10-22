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
          // عرض رسالة الخطأ فقط (AddFavoriteSuccess غير معرّفة في الـ States الحالية)
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
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
                            : const {'car_ads': 'سيارات','real_estate_ads': 'عقارات','car_parts_ads': 'قطع غيار','other_ads': 'أخرى'},
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

  @override
  bool get wantKeepAlive => true;
}