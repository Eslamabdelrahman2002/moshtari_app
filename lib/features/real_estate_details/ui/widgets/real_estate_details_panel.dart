import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/utils/helpers/time_from_now.dart';
import 'package:mushtary/core/utils/json/areas_sa.dart';
import 'package:mushtary/core/utils/json/cites_sa.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_item_datails.dart';

class DetailsPanel extends StatelessWidget {
  final String? cityName;
  final String? areaName;
  final DateTime createdAt;
  const DetailsPanel({
    super.key,
    this.cityName,
    this.areaName,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // Safely find the city and area names
    // final cityName = Cites.cites
    //     .firstWhereOrNull((city) => city.id == cityName)
    //     ?.cityNameAr ??
    //     'مدينة غير معروفة';
    // final areaName = Areas.areas
    //     .firstWhereOrNull((area) => area.areaId == areaName)
    //     ?.areaNameAr ??
    //     'حي غير معروف';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RealEstateItemDatails(
                      text: (cityName != null && areaName != null)
                          ? '$cityName - $areaName'
                          : 'N/A',
                      image: 'location-yellow',
                      width: 20.w,
                      height: 20.h,
                    ),
                    const Spacer(),
                    RealEstateItemDatails(
                      text:"${createdAt.year}-${createdAt.month}-${createdAt.day}",
                      image: 'clock-yellow',
                      width: 20.w,
                      height: 20.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        verticalSpace(12),
      ],
    );
  }
}