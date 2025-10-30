// file: real_estate_ads.dart

import 'package:flutter/material.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_grid_view.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_list_view.dart';
// import 'package:mushtary/features/real_estate_applications_deatils/widgets/real_estate_applications.dart'; // ❌ تم حذف هذا الاستيراد المفقود

class RealEstateAds extends StatelessWidget {
  final bool isListView;
  final bool isGridView;
  final bool isMapView;
  final bool isApplications;
  final List<RealEstateListModel> properties;

  const RealEstateAds({
    super.key,
    required this.isListView,
    required this.isGridView,
    required this.isMapView,
    required this.isApplications,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ⚠️ يجب التأكد من أن isApplications دائمًا false مؤقتاً إذا لم يكن لديك الـ Widget
        // Visibility(
        //   visible: (!isMapView && !isApplications),
        //   child: setupListOrGridView(),
        // ),
        // Visibility(
        //   visible: (isApplications),
        //   child: const Expanded(child: RealEstateApplications()), // ❌ تم حذف هذا الكود
        // ),
        // ✅ استخدام منطق بسيط لتمكين عرض القائمة/الشبكة
        if (!isMapView && !isApplications)
          setupListOrGridView(),
        // إذا كنت تريد التعامل مع isApplications
        if (isApplications)
          const Expanded(child: Center(child: Text('Applications Screen Not Implemented Yet'))),
      ],
    );
  }

  Widget setupListOrGridView() {
    if (isListView) {
      return RealEstateListView(properties: properties);
    } else {
      return RealEstateGridView(properties: properties);
    }
  }
}