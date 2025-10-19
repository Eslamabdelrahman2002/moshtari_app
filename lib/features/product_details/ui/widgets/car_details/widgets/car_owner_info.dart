// lib/features/car_details/ui/widgets/car_details/widgets/car_owner_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CarOwnerInfo extends StatelessWidget {
  final String username;
  final String? phone;

  const CarOwnerInfo({super.key, required this.username, this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFEFEF)),
            alignment: Alignment.center,
            child: const MySvg(image: 'user'),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: TextStyles.font14Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    const MySvg(image: 'call', color: Colors.grey),
                    SizedBox(width: 6.w),
                    Text(phone?.trim().isNotEmpty == true ? phone! : 'لا يوجد', style: TextStyles.font12DarkGray400Weight),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}