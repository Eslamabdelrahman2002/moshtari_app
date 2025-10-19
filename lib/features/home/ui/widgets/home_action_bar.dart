import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class HomeActionBar extends StatelessWidget {
  final VoidCallback onListViewTap;
  final VoidCallback onGridViewTap;
  final VoidCallback onReelsViewTap;
  final bool isListView;
  final bool isAuctionsView;
  final ValueChanged<bool> onAuctionsViewChanged;

  const HomeActionBar({
    super.key,
    required this.onListViewTap,
    required this.onGridViewTap,
    required this.isListView,
    required this.onReelsViewTap,
    required this.isAuctionsView,
    required this.onAuctionsViewChanged,
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
            horizontalSpace(8),
            InkWell(
              onTap: onReelsViewTap,
              child: Container(
                padding: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  color: ColorsManager.lightYellow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const MySvg(image: 'slider_view'),
              ),
            ),
            const Spacer(),
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                value: isAuctionsView,
                activeColor: ColorsManager.primaryColor,
                onChanged: onAuctionsViewChanged,
              ),
            ),
            horizontalSpace(10),
            Text(
              'المزادات',
              style: TextStyles.font16Black500Weight,
            ),
            horizontalSpace(4),
            const MySvg(image: 'judge'),
          ],
        ),
      ),
    );
  }
}