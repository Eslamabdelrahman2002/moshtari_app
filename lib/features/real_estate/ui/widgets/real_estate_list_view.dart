import 'package:flutter/material.dart';
// ✨ 1. IMPORT the new model
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_list_view_item.dart';

class RealEstateListView extends StatelessWidget {
  // ✨ 2. CHANGE the list type here
  final List<RealEstateListModel> properties;

  const RealEstateListView({
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
      child: ListView.builder(
        itemCount: properties.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // Now it correctly passes a RealEstateAdModel to the item widget
          return RealEstateListViewItem(
            property: properties[index],
          );
        },
      ),
    );
  }
}