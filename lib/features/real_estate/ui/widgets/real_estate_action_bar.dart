// file: real_estate_action_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_drop_down.dart';

class RealEstateActionBar extends StatelessWidget {
  final VoidCallback onListViewTap;
  final VoidCallback onGridViewTap;
  final VoidCallback onMapViewTap;
  final VoidCallback onCityTap;
  final bool isListView;
  final bool isGridView;
  final bool isMapView;
  final bool isApplications;

  const RealEstateActionBar({
    super.key,
    required this.onListViewTap,
    required this.onGridViewTap,
    required this.isListView,
    required this.onMapViewTap,
    required this.isGridView,
    required this.isMapView,
    required this.isApplications,
    required this.onCityTap, // ✅ إضافة دالة اختيار المدينة
  });

  Widget _modeIcon({required bool active, required String image, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: active ? ColorsManager.secondary500 : ColorsManager.lightYellow,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: MySvg(
          image: active ? '${image}_active' : image,
          width: 20.w,
          height: 20.w,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Visibility(
              visible: !isApplications,
              child: Row(
                children: [
                  // عرض الشبكة
                  _modeIcon(
                    active: isGridView,
                    image: 'gridView',
                    onTap: onGridViewTap,
                  ),
                  horizontalSpace(8),
                  // عرض القائمة
                  _modeIcon(
                    active: isListView,
                    image: 'listView',
                    onTap: onListViewTap,
                  ),
                  horizontalSpace(8),


                ],
              ),
            ),
            const Spacer(),

            // زر اختيار المدينة
            InkWell(
              onTap: onCityTap, // ربط بـ دالة onCityTap الممررة
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(color: ColorsManager.lightYellow, borderRadius: BorderRadius.circular(8.r)),
                child: Row(
                  children: [
                    const Icon(Icons.place_rounded, size: 16, color: ColorsManager.secondary500),
                    SizedBox(width: 6.w),
                    Text('المدينة', style: TextStyles.font12DarkGray400Weight),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}