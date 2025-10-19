import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import 'package:mushtary/features/create_ad/ui/screens/cars/cars_advanced_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/cars/cars_display_information_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/cars/cars_select_category_details_screen.dart';

import 'package:mushtary/features/create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_cubit.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_advanced_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_select_category_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_view_iformations_screen.dart';

import 'package:mushtary/features/create_ad/ui/widgets/create_ad_app_bar.dart';
import 'package:mushtary/features/create_ad/ui/widgets/create_ad_manual_category_step.dart';
import 'package:mushtary/features/create_ad/ui/widgets/steps_header_rtl.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import '../../../../core/enums/create_ad_category.dart';

// إلكترونيات (Placeholder)
import '../../../ad_action/ui/screens/car_auction_start_screen.dart' hide StepsHeaderRtl;
import 'car_parts/electronics_advanced_details_screen.dart';
import 'car_parts/electronics_select_category_details_screen.dart';
import 'car_parts/electronics_view_iformations_screen.dart';

import 'cars/logic/cubit/car_ads_cubit.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});
  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  late PageController pageController;
  int currentPage = 0;
  CreateAdCategory category = CreateAdCategory.cars;

  bool _navLock = false;
  Future<void> _pushOnce(Future<void> Function() action) async {
    if (_navLock) return;
    _navLock = true;
    try {
      await action();
    } finally {
      if (mounted) _navLock = false;
    }
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  static const _stepLabels = ['حدد التصنيف', 'تفاصيل متقدمة', 'معلومات العرض'];

  int get _headerCurrentIndex {
    final i = currentPage - 1;
    if (i <= 0) return 0;
    if (i == 1) return 1;
    return 2;
  }

  void _goToHeaderStep(int step) {
    final target = 1 + step; // step 0..2 -> page 1..3
    pageController.animateToPage(target, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final showHeader = category.index == 0 || category.index == 1;

    return MultiBlocProvider(
      providers: [
        BlocProvider<CarAdsCubit>(create: (context) => getIt<CarAdsCubit>()),
        BlocProvider<RealEstateAdsCubit>(create: (context) => getIt<RealEstateAdsCubit>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              CreateAdAppBar(pop: currentPage == 0 ? null : _goToPreviousPage),
              verticalSpace(8),

              if (showHeader)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: StepsHeaderRtl(
                    labels: _stepLabels,
                    current: _headerCurrentIndex,
                    onTap: _goToHeaderStep,
                  ),
                ),

              if (showHeader) verticalSpace(8),

              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: _pages(context)[category.index].length,
                  onPageChanged: (index) => setState(() => currentPage = index),
                  itemBuilder: (context, index) => _pages(context)[category.index][index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(CreateAdCategory cat) {
    if (cat == CreateAdCategory.devices) {
      _pushOnce(() => Navigator.of(context).pushNamed(Routes.createCarPartAdStep1));
      return;
    }
    if (cat == CreateAdCategory.other) {
      _pushOnce(() => Navigator.of(context).pushNamed(Routes.createOtherAdStep2));
      return;
    }
    setState(() => category = cat);
    pageController.jumpToPage(1);
  }

  void _goToNextPage() => pageController.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  void _goToPreviousPage() => pageController.previousPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  List<List<Widget>> _pages(BuildContext context) => [
    // Cars
    [
      // بدون أي هيدر داخلي أو عنوان "اختيار يدويًا"
      CreateAdManualCategoryStep(onTap: _onCategorySelected),
      CarsSelectCategoryDetailsScreen(onPressed: _goToNextPage),
      CarsAdvancedDetailsScreen(onPressed: _goToNextPage),
      CarsDisplayInformationScreen(
        onPressed: () => context.read<CarAdsCubit>().submit(),
      ),
    ],
    // Real Estate
    [
      CreateAdManualCategoryStep(onTap: _onCategorySelected),
      RealEstateSelectCategoryDetailsScreen(onNext: _goToNextPage),
      RealEstateAdvancedDetailsScreen(onNext: _goToNextPage),
      const RealEstateViewIformationsScreen(),
    ],
    // Electronics
    [
      CreateAdManualCategoryStep(onTap: _onCategorySelected),
      const ElectronicsSelectCategoryDetailsScreen(),
      const ElectronicsAdvancedDetailsScreen(),
      const ElectronicsViewIformationsScreen(),
    ],
    // Other (Router)
    [
      CreateAdManualCategoryStep(onTap: _onCategorySelected),
      const SizedBox.shrink(),
    ],
  ];
}