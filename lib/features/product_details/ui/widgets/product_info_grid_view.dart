import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/home/data/models/auctions/car_model.dart';
import 'package:mushtary/features/product_details/ui/widgets/product_info.dart';

class ProductInfoGridView extends StatelessWidget {
  final CarModel car;
  const ProductInfoGridView({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 358.w,
        decoration: BoxDecoration(
          color: ColorsManager.primary50,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: GridView(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            crossAxisCount: 3,
          ),
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            ProductInfoItem(
              title: '${car.kilometers ?? ''} km',
              icon: 'km_counter',
            ),
            ProductInfoItem(
              title: car.gearType ?? '',
              icon: 'gear',
            ),
            ProductInfoItem(
              title: '${car.cylinderCount ?? ''} سلندر',
              icon: 'cylinder',
            ),
            ProductInfoItem(
              title: car.color ?? '',
              icon: 'car_color',
            ),
            ProductInfoItem(
              title: car.fuelType ?? '',
              icon: 'fuel',
            ),
            ProductInfoItem(
              title: car.wheelDriveType ?? '',
              icon: 'wheel',
            ),
          ],
        ));
  }
}
