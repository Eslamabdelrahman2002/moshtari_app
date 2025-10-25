import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_ads.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_app_bar.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../../data/model/real_estate_filter_params.dart';
import '../../logic/cubit/real_estate_cubit.dart';
import '../../logic/cubit/real_estate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          Expanded(
            child: BlocBuilder<RealEstateCubit, RealEstateState>(
              builder: (context, state) {
                if (state is RealEstateLoading) {
                  return _RealEstateGridSkeleton();
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
                return const Center(child: Text('Please select filters to see ads.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RealEstateGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        physics: const BouncingScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 10.h),
                child: Column(
                  children: [
                    Container(height: 12.h, width: double.infinity, color: Colors.white),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(child: Container(height: 10.h, color: Colors.white)),
                        SizedBox(width: 8.w),
                        Container(height: 10.h, width: 50.w, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}