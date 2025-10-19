// lib/features/car_details/ui/widgets/car_info_grid_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_product_info.dart';

class CarInfoGridView extends StatelessWidget {
  final String? transmission;
  final String? mileage;
  final int? cylinder;
  final String? driveType;
  final String? horsepower;
  final String? fuelType;
  final String? vehicleType; // لو حاب تستخدمه لاحقاً

  const CarInfoGridView({
    super.key,
    this.transmission,
    this.mileage,
    this.cylinder,
    this.driveType,
    this.horsepower,
    this.fuelType,
    this.vehicleType,
  });

  // ترجع "لا يوجد" لو null أو فاضي/مسافة، وتضيف لاحقة لو مطلوبة
  String _text(Object? v, {String? suffix, bool treatZeroAsEmpty = false}) {
    if (v == null) return 'لا يوجد';

    if (v is String) {
      final t = v.trim();
      if (t.isEmpty || t.toLowerCase() == 'null') return 'لا يوجد';
      return suffix == null ? t : '$t $suffix';
    }

    if (v is num) {
      if (treatZeroAsEmpty && v == 0) return 'لا يوجد';
      final t = v.toString();
      return suffix == null ? t : '$t $suffix';
    }

    final t = v.toString().trim();
    if (t.isEmpty) return 'لا يوجد';
    return suffix == null ? t : '$t $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                title: _text(transmission),
                icon: 'transmission',
              ),
              RealEstateProductInfo(
                title: _text(mileage, suffix: 'كم'),
                icon: 'ic_round-speed',
              ),
              RealEstateProductInfo(
                title: _text(cylinder, suffix: 'سلندر', treatZeroAsEmpty: true),
                icon: 'tabler_engine',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                title: _text(fuelType),
                icon: 'call-calling',
              ),
              RealEstateProductInfo(
                title: _text(driveType),
                icon: 'four wheel',
              ),
              RealEstateProductInfo(
                title: _text(horsepower, suffix: 'حصان'),
                icon: 'piston',
              ),
            ],
          ),
        ],
      ),
    );
  }
}