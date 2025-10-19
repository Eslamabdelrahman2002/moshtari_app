import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_product_info.dart';

import '../../data/model/car_auction_details_model.dart';

class AuctionCarInfoGridView extends StatelessWidget {
  final CarAuctionActiveItem item;

  const AuctionCarInfoGridView({super.key, required this.item});

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
          // الصف الأول
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                title: _text(item.drivetrain),          // نظام الدفع
                icon: 'transmission',
              ),
              RealEstateProductInfo(
                title: _text(item.kilometers, suffix: 'كم'), // الممشى
                icon: 'ic_round-speed',
              ),
              RealEstateProductInfo(
                title: _text(item.cylinders, suffix: 'سلندر', treatZeroAsEmpty: true), // السلندرات
                icon: 'tabler_engine',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // الصف الثاني
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                title: _text(item.engineCapacity, suffix: 'لتر'), // السعة
                icon: 'piston',
              ),
              RealEstateProductInfo(
                title: _text(
                  (item.brand?.name.isNotEmpty == true ? item.brand!.name : null) ??
                      (item.model?.nameAr.isNotEmpty == true ? item.model!.nameAr : item.model?.nameEn),
                ), // الماركة/الموديل
                icon: 'car-duotone',
              ),
              RealEstateProductInfo(
                title: _text(item.year, treatZeroAsEmpty: true), // السنة
                icon: 'calendar', // لو عندك أيقونة تقويم، وإلا اترك الحالية لديك
              ),
            ],
          ),
        ],
      ),
    );
  }
}