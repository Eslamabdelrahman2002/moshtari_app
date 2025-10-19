import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ✨ 1. IMPORT the new API model
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_grid_view_item.dart';

// ❌ REMOVE the old mock data import
// import '../../data/model/mock_data.dart';

class RealEstateGridView extends StatelessWidget {
  // ✨ 2. CHANGE the list type to use the new model
  final List<RealEstateListModel> properties;

  const RealEstateGridView({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('لا يوجد عروض لهذه الفئة'),
        ),
      );
    }
    return Expanded(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 18.h,
            childAspectRatio: 0.9,
            crossAxisCount: 2,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shrinkWrap: true,
          itemCount: properties.length,
          itemBuilder: (context, index) {
            // ✨ 3. Now it correctly passes a RealEstateAdModel to the item widget
            return RealEstateGridViewItem(
              property: properties[index],
            );
          },
        ));
  }
}