import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_advertise_type_section.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_other_section.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_range_slider_section.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_single_slider_section.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/filter_status_section.dart';

class HomeFilterWidget extends StatefulWidget {
  const HomeFilterWidget({
    super.key,
  });

  @override
  State<HomeFilterWidget> createState() => _HomeFilterWidgetState();
}

class _HomeFilterWidgetState extends State<HomeFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            const SizedBox.shrink(),
            Text(
              'تصفية',
              style: TextStyles.font20Black500Weight,
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'مسح الكل',
                style: TextStyles.font14Red500Weight,
              ),
            ),
          ],
        ),
        verticalSpace(32),
        SizedBox(
          height: 500.h,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const FilterRangeSliderSection(),
                verticalSpace(32),
                const FilterStatusSection(),
                verticalSpace(32),
                const FilterAdvertiseTypeSection(),
                verticalSpace(32),
                const FilterOtherSection(),
                verticalSpace(32),
                const FilterSingleSliderSection(),
              ],
            ),
          ),
        ),
        verticalSpace(16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorsManager.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 20.r,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'تطبيق الفلتر',
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              horizontalSpace(24),
              Expanded(
                child: PrimaryButton(
                  text: 'رجوع',
                  textColor: ColorsManager.darkFontColor,
                  backgroundColor: ColorsManager.buttonGray,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
