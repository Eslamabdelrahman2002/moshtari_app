// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mushtary/core/router/routes.dart';
// import 'package:mushtary/core/theme/colors.dart';
// import 'package:mushtary/core/utils/helpers/navigation.dart';
// import 'package:mushtary/core/utils/helpers/spacing.dart';
// import 'package:mushtary/features/home/ui/widgets/home_action_bar.dart';
// import 'package:mushtary/features/home/ui/widgets/home_banners.dart';
// import 'package:mushtary/features/home/ui/widgets/home_grid_view.dart';
// import 'package:mushtary/features/home/ui/widgets/home_list_view.dart';
// import 'package:mushtary/features/home/ui/widgets/home_screen_app_bar.dart';
// import '../../../../core/dependency_injection/injection_container.dart';
//
// import '../../../favorites/ui/logic/cubit/favorites_cubit.dart';
// import '../../data/models/home_data_model.dart';
// import '../../logic/cubit/home_cubit.dart';
// import '../../logic/cubit/home_state.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => getIt<HomeCubit>()..fetchHomeData()),
//         BlocProvider(create: (context) => getIt<FavoritesCubit>()..fetchFavorites()),
//       ],
//       child: const HomeView(),
//     );
//   }
// }
//
// class HomeView extends StatefulWidget {
//   const HomeView({super.key});
//
//   @override
//   State<HomeView> createState() => _HomeViewState();
// }
//
// class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
//   bool isListView = false;
//   bool _showAuctions = false;
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return DefaultTabController(
//       length: 5, // 🟡 الرئيسية - سيارات - عقارات - قطع غيار - أخرى
//       child: Scaffold(
//         body: SafeArea(
//           child: BlocBuilder<HomeCubit, HomeState>(
//             builder: (context, state) {
//               if (state is HomeLoading || state is HomeInitial) {
//                 return const Center(child: CircularProgressIndicator.adaptive());
//               }
//               if (state is HomeFailure) {
//                 return Center(child: Text(state.error));
//               }
//               if (state is HomeSuccess) {
//                 final homeData = state.homeData;
//
//                 return NestedScrollView(
//                   headerSliverBuilder: (context, innerBoxIsScrolled) {
//                     return [
//                       // 🔹 AppBar الرئيسي
//                       SliverAppBar(
//                         pinned: true,
//                         floating: true,
//                         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//                         elevation: 0,
//                         toolbarHeight: 70.h,
//                         flexibleSpace: HomeScreenAppBar(
//                           onMenuTap: () => context.pushNamed(Routes.menuScreen),
//                           onNotificationsTap: () => context.pushNamed(Routes.notificationScreen),
//                         ),
//                       ),
//
//                       SliverToBoxAdapter(child: verticalSpace(16.0)),
//
//                       // 🔹 البانرز
//                       const SliverToBoxAdapter(child: HomeBanners()),
//
//                       SliverToBoxAdapter(child: verticalSpace(16.0)),
//
//                       // 🔹 TabBar (الكاتوجري) – مستقل بعد البانر
//                       SliverToBoxAdapter(
//                         child: Container(
//                           color: Theme.of(context).scaffoldBackgroundColor,
//                           child: const TabBar(
//                             isScrollable: true,
//                             labelColor: ColorsManager.primaryColor,
//                             unselectedLabelColor: Colors.grey,
//                             indicatorColor: ColorsManager.primaryColor,
//                             tabs: [
//                               Tab(text: "الرئيسية"),
//                               Tab(text: "سيارات"),
//                               Tab(text: "عقارات"),
//                               Tab(text: "قطع غيار"),
//                               Tab(text: "أخرى"),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       SliverToBoxAdapter(child: verticalSpace(16.0)),
//
//                       // 🔹 ActionBar (Grid/List/Auctions)
//                       SliverAppBar(
//                         pinned: true,
//                         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//                         toolbarHeight: 60.h,
//                         flexibleSpace: HomeActionBar(
//                           onGridViewTap: () => setState(() => isListView = false),
//                           onListViewTap: () => setState(() => isListView = true),
//                           onReelsViewTap: () => context.pushNamed(
//                             Routes.reelsScreen,
//                             arguments: [
//                               ...homeData.carAds,
//                               ...homeData.realEstateAds,
//                               ...homeData.carPartsAds,
//                               ...homeData.otherAds,
//                             ]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
//                           ),
//                           isListView: isListView,
//                           isAuctionsView: _showAuctions,
//                           onAuctionsViewChanged: (value) {
//                             setState(() {
//                               _showAuctions = value;
//                             });
//                           },
//                         ),
//                       ),
//                     ];
//                   },
//
//                   // 🔹 محتوى كل تبويب
//                   body: TabBarView(
//                     children: [
//                       // 🏠 الرئيسية (كل الإعلانات)
//                       _buildAdsList([
//                         ...homeData.carAds,
//                         ...homeData.realEstateAds,
//                         ...homeData.carPartsAds,
//                         ...homeData.otherAds,
//                       ]),
//
//                       // 🚗 سيارات
//                       _buildAdsList(homeData.carAds),
//
//                       // 🏡 عقارات
//                       _buildAdsList(homeData.realEstateAds),
//
//                       // ⚙️ قطع غيار
//                       _buildAdsList(homeData.carPartsAds),
//
//                       // 📦 أخرى
//                       _buildAdsList(homeData.otherAds),
//                     ],
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAdsList(List<HomeAdModel> ads) {
//     return CustomScrollView(
//       slivers: [
//         SliverPadding(
//           padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
//           sliver: isListView ? HomeListView(ads: ads) : HomeGridView(ads: ads),
//         ),
//       ],
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }