import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_ads.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_app_bar.dart';

import '../../data/model/real_estate_filter_params.dart';
import '../../logic/cubit/real_estate_cubit.dart';
import '../../logic/cubit/real_estate_state.dart';

class RealEstateBody extends StatefulWidget {
  const RealEstateBody({super.key});

  @override
  State<RealEstateBody> createState() => _RealEstateBodyState();
}

class _RealEstateBodyState extends State<RealEstateBody> {
  @override
  void initState() {
    super.initState();
    context
        .read<RealEstateCubit>()
        .fetchRealEstateAds(RealEstateFilterParams(sortBy: 'latest'));
  }

  @override
  Widget build(BuildContext context) {
    const bool isApplications = false;
    const bool isListView = false;
    const bool isGridView = true;
    const bool isMapView = false;

    return SafeArea(
      child: Column(
        children: [
          const RealEstateAppBar(),
          verticalSpace(8),

          // ✨ FIX: Wrap the BlocBuilder with an Expanded widget
          Expanded(
            child: BlocBuilder<RealEstateCubit, RealEstateState>(
              builder: (context, state) {
                if (state is RealEstateLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RealEstateError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is RealEstateLoaded) {
                  if (state.ads.isEmpty) {
                    return const Center(child: Text('لا يوجد عروض لهذه الفئة'));
                  }
                  return RealEstateAds(
                    isApplications: isApplications,
                    isGridView: isGridView,
                    isListView: isListView,
                    isMapView: isMapView,
                    properties: state.ads,
                  );
                }
                // Initial state
                return const Center(
                    child: Text('Please select filters to see ads.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}