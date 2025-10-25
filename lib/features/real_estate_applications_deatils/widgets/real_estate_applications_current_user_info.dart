import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_stars_rate.dart';

class RealEstateApplicationsCurrentUserInfo extends StatelessWidget {
  const RealEstateApplicationsCurrentUserInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      // height: 57.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: ColorsManager.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 0,
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ]),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/prof.png',
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
            ),
          ),
          horizontalSpace(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'اسم المستخدم',
                    style: TextStyles.font14Black500Weight,
                  ),
                  horizontalSpace(8),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: ColorsManager.lightTeal,
                      borderRadius: BorderRadius.circular(80.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'موثق',
                          style: TextStyles.font12Green400Weight,
                        ),
                        horizontalSpace(2),
                        Icon(
                          Icons.verified,
                          color: ColorsManager.teal,
                          size: 12.w,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              verticalSpace(4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const RealEstateStarsRate(rate: 3),
                  horizontalSpace(8),
                  Text('( 5 اراء )',
                      style: TextStyles.font10Dark400Grey400Weight),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: ColorsManager.secondary50,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MySvg(
                  image: 'global-search',
                  width: 16.w,
                  height: 16.h,
                ),
                horizontalSpace(2),
                Text(
                  'باحث عن عقار',
                  style: TextStyles.font12secondary500yellow400Weight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}