// lib/features/real_estate_details/ui/widgets/real_estate_product_info_grid_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_product_info.dart';

class RealEstateProductInfoGridView extends StatelessWidget {
  final int? area;
  final int? rooms;
  final int? bathrooms;
  final String? windDirection;
  final int? numberOfStreetFrontages;
  final int? streetWidth;

  const RealEstateProductInfoGridView({
    super.key,
    this.area,
    this.rooms,
    this.bathrooms,
    this.windDirection,
    this.numberOfStreetFrontages,
    this.streetWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الصف الأول
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                title: area != null ? '$area م²' : 'غير محدد',
                icon: 'ruler-primary400',
              ),
              RealEstateProductInfo(
                title: rooms != null ? '$rooms غرف' : 'غير محدد',
                icon: 'bed-primary400',
              ),
              RealEstateProductInfo(
                title: bathrooms != null ? '$bathrooms حمام' : 'غير محدد',
                icon: 'shower-primary400',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // الصف الثاني
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                title: windDirection ?? 'غير محدد',
                icon: 'wind-primary400',
              ),
              RealEstateProductInfo(
                title: numberOfStreetFrontages != null
                    ? '$numberOfStreetFrontages شارع'
                    : 'غير محدد',
                icon: 'street-sign-primary400',
              ),
              RealEstateProductInfo(
                title: streetWidth != null ? '$streetWidth م' : 'غير محدد',
                icon: 'road-icon-primary400',
              ),
            ],
          ),
        ],
      ),
    );
  }
}