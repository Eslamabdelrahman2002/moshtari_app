import 'package:flutter/material.dart';
import 'package:mushtary/features/real_estate_applications_deatils/widgets/real_estate_applications_details_body.dart';

import '../../real_estate/data/model/mock_data.dart';
import '../../real_estate_details/ui/widgets/real_estate_navigation_bar.dart';

class RealEstateApplicationsDetailsScreen extends StatelessWidget {
  final RealStateApplicationsDetailsModel realStateApplicationsDetailsModel;
  const RealEstateApplicationsDetailsScreen(
      {super.key, required this.realStateApplicationsDetailsModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RealEstateApplicationsDetailsBody(
        realStateApplicationsDetailsModel: realStateApplicationsDetailsModel,
      ),
      bottomNavigationBar: const RealEstateNavigationBar(),
    );
  }
}
