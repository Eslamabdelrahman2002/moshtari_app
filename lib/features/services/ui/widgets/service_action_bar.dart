// features/services/ui/widgets/service_action_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ServiceActionBar extends StatelessWidget {
  final VoidCallback onListViewTap;
  final VoidCallback onGridViewTap;
  final bool isListView;

  const ServiceActionBar({
    super.key,
    required this.onListViewTap,
    required this.onGridViewTap,
    required this.isListView,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            InkWell(
              onTap: onGridViewTap,
              child: Container(
                padding: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  color: isListView
                      ? ColorsManager.lightYellow
                      : ColorsManager.secondary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: isListView
                    ? const MySvg(image: 'gridView')
                    : const MySvg(image: 'gridView_active'),
              ),
            ),
            horizontalSpace(8),
            InkWell(
              onTap: onListViewTap,
              child: Container(
                padding: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  color: isListView
                      ? ColorsManager.secondary
                      : ColorsManager.lightYellow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: isListView
                    ? const MySvg(image: 'listView_active')
                    : const MySvg(image: 'listView'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}