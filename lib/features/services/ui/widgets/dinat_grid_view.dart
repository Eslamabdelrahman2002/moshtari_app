// lib/features/services/ui/widgets/dinat_grid_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/model/dinat_trip.dart';
import 'dinat_grid_item.dart';

class DinatGridView extends StatelessWidget {
  final List<DynaTrip> trips;
  final EdgeInsets? padding;

  const DinatGridView({
    super.key,
    required this.trips,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding ?? EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
              (context, index) => DinatGridItem(trip: trips[index]),
          childCount: trips.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.60,
        ),
      ),
    );
  }
}