import 'package:flutter/material.dart';
import 'package:mushtary/features/real_estate/data/model/mock_data.dart';
import 'package:mushtary/features/real_estate_applications_deatils/widgets/property_card.dart';

class RealEstateApplications extends StatelessWidget {
  const RealEstateApplications({super.key});

  @override
  Widget build(BuildContext context) {
    // بناء الواجهة مباشرة من البيانات الوهمية
    return _buildApplications(mockApplications);
  }

  Widget _buildApplications(List<RealStateApplicationsDetailsModel> data) {
    return ListView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      // The physics can be set to NeverScrollableScrollPhysics if this ListView is inside another scrollable widget.
      // physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = data[index];
        // FIX: The type mismatch errors are resolved because mockApplications
        // now uses the correct, unified enums from the corrected mock_data.dart file.
        return PropertyCard(
          realStateApplicationsDetailsModel: item,
          applicationType: item.applicationType!,
          propertyUserType: item.propertyUserType!,
          time: item.createdAt!,
          location: item.location!,
          title: item.title!,
          lowestPrice: item.lowestPrice!,
          highestPrice: item.highestPrice!,
          lowestArea: item.lowestArea!,
          highestArea: item.highestArea!,
        );
      },
    );
  }
}

