// lib/features/car_details/ui/widgets/car_details/widgets/car_details_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class CarDetailsPanel extends StatelessWidget {
  final String city;
  final String region;
  final DateTime createdAt;
  const CarDetailsPanel({super.key, required this.city, required this.region, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final date = "${createdAt.year}-${createdAt.month}-${createdAt.day}";
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const MySvg(image: 'location-yellow'),
                    SizedBox(width: 6.w),
                    Expanded(child: Text("$city - $region", style: TextStyles.font14Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              Row(
                children: [
                  const MySvg(image: 'clock-yellow'),
                  SizedBox(width: 6.w),
                  Text(date, style: TextStyles.font14Black500Weight),
                ],
              ),
            ],
          ),
        ),
        verticalSpace(12),
      ],
    );
  }
}