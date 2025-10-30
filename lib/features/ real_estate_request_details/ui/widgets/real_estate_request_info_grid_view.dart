import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_product_info.dart'; // إعادة استخدام ويدجت العنصر الواحد
import '../../data/model/real_estate_request_details_model.dart'; // استيراد موديل الطلب

class RealEstateRequestInfoGridView extends StatelessWidget {
  final RealEstateRequestSpecs? specs;

  const RealEstateRequestInfoGridView({
    super.key,
    required this.specs,
  });

  // دالة مساعدة لتحويل Range إلى نص العرض
  String _getRangeText(dynamic range) {
    if (range == null) return 'غير محدد';
    return range.toString();
  }

  @override
  Widget build(BuildContext context) {
    final s = specs;

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
          // الصف الأول: المساحة، الغرف، الحمامات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                // المساحة تستخدم RangeString
                title: '${_getRangeText(s?.areaM2)} م²',
                icon: 'ruler-primary400',
              ),
              RealEstateProductInfo(
                title: s?.roomCount != null ? '${s!.roomCount} غرف' : 'غير محدد',
                icon: 'bed-primary400',
              ),
              RealEstateProductInfo(
                title: s?.bathroomCount != null ? '${s!.bathroomCount} حمام' : 'غير محدد',
                icon: 'shower-primary400',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // الصف الثاني: الواجهة، عرض الشارع، الصالات/الأدوار (اختياري)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RealEstateProductInfo(
                title: s?.facade ?? 'غير محدد',
                icon: 'wind-primary400',
              ),
              RealEstateProductInfo(
                // عرض الشارع يستخدم RangeInt
                title: '${_getRangeText(s?.streetWidth)} م',
                icon: 'road-icon-primary400', // استخدام رمز الطريق بدلاً من الشارع
              ),
              RealEstateProductInfo(
                title: s?.floorCount != null ? '${s!.floorCount} دور' : 'غير محدد',
                icon: 'street-sign-primary400', // استخدام رمز مختلف
              ),
            ],
          ),
        ],
      ),
    );
  }
}