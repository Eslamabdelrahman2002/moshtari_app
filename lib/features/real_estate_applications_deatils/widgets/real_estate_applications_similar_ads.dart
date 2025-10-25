import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/enums.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/real_estate_applications_deatils/widgets/property_card.dart';

class RealEstateApplicationsSimilarAds extends StatelessWidget {
  const RealEstateApplicationsSimilarAds({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: 300.w,
                height: 120.w,
                child: FittedBox(
                  child: PropertyCard(
                    // FIX: Using valid enum values
                    applicationType: RealStateApplicationType.building,
                    propertyUserType: RealStateUserTypes.buyer,
                    time: DateTime.now().subtract(const Duration(days: 1)),
                    location: 'الرياض - حي النرجس الشرقي',
                    title: 'مطلوب فيلا للبيع',
                    lowestPrice: '1,000,000',
                    highestPrice: '5,000,000',
                    lowestArea: '700',
                    highestArea: '1,000',
                  ),
                ),
              ),
            ),
            horizontalSpace(12),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: 300.w,
                height: 120.w,
                child: FittedBox(
                  child: PropertyCard(
                    // FIX: Using valid enum values
                    applicationType: RealStateApplicationType.villa,
                    propertyUserType: RealStateUserTypes.seller,
                    time: DateTime.now().subtract(const Duration(days: 1)),
                    location: 'الرياض - حي النرجس الشرقي',
                    title: 'مطلوب فيلا للبيع',
                    lowestPrice: '1,000,000',
                    highestPrice: '5,000,000',
                    lowestArea: '700',
                    highestArea: '1,000',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}