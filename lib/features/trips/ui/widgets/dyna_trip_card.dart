import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import '../../data/model/dyna_trips_list_models.dart';


class DynaTripCard extends StatelessWidget {
  final DynaTripItem item;
  final VoidCallback? onDetails;

  const DynaTripCard({super.key, required this.item, this.onDetails});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final dep = item.departureDate != null ? df.format(item.departureDate!) : '-';
    final arr = item.arrivalDate != null ? df.format(item.arrivalDate!) : '-';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            'طلب نقل — من ${item.fromCityNameAr} إلى ${item.toCityNameAr}',
            style: TextStyles.font14Black500Weight,
          ),
          SizedBox(height: 10.h),

          // من -> إلى
          Row(
            children: [
              Icon(Icons.place, size: 16.r, color: ColorsManager.darkGray),
              SizedBox(width: 4.w),
              Text(item.fromCityNameAr, style: TextStyles.font12DarkGray400Weight),
              SizedBox(width: 8.w),
             Text('--->',style: TextStyle(color: ColorsManager.primaryColor),),
              SizedBox(width: 8.w),
              Icon(Icons.location_on_outlined, size: 16.r, color: ColorsManager.darkGray),
              SizedBox(width: 4.w),
              Text(item.toCityNameAr, style: TextStyles.font12DarkGray400Weight),
            ],
          ),
          SizedBox(height: 10.h),

          // معلومات الرحلة
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _IconText(icon: Icons.event, text: dep),
              _IconText(icon: Icons.access_time, text: arr),
              _IconText(icon: Icons.local_shipping_outlined, text: 'السعة: ${item.dynaCapacity}'),
            ],
          ),
          SizedBox(height: 12.h),

          // Align(
          //   alignment: Alignment.centerRight,
          //   child: SizedBox(
          //     height: 36.h,
          //     child: OutlinedButton(
          //       onPressed: onDetails,
          //       style: OutlinedButton.styleFrom(
          //         backgroundColor:ColorsManager.primaryColor,
          //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          //       ),
          //       child: Text('عرض التفاصيل', style: TextStyle(color: ColorsManager.white, fontWeight: FontWeight.w600)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.r, color: ColorsManager.darkGray),
        SizedBox(width: 4.w),
        Text(text, style: TextStyles.font12DarkGray400Weight),
      ],
    );
  }
}