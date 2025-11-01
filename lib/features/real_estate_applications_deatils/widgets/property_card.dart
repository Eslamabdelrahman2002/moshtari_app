import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/enums.dart' as enums; // ✅ Perfect
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/utils/helpers/time_from_now.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/real_estate_applications_deatils/widgets/real_state_application_user_section.dart';
import '../../real_estate/data/model/mock_data.dart';

class PropertyCard extends StatelessWidget {
  final String title;
  final DateTime time;
  final String location;
  final String lowestPrice;
  final String highestPrice;
  final String lowestArea;
  final String highestArea;
  final enums.RealStateApplicationType applicationType; // ✅ Correct Type
  final enums.RealStateUserTypes propertyUserType;       // ✅ Correct Type
  final RealStateApplicationsDetailsModel? realStateApplicationsDetailsModel;

  const PropertyCard({
    super.key,
    required this.title,
    required this.time,
    required this.location,
    required this.lowestPrice,
    required this.highestPrice,
    required this.lowestArea,
    required this.highestArea,
    required this.applicationType,
    required this.propertyUserType,
    this.realStateApplicationsDetailsModel,
  });

  @override
  Widget build(BuildContext context) {
    // ... محتوى الكلاس لا يحتاج أي تغيير
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.realEstateApplicationsDetailsScreen,
          arguments: realStateApplicationsDetailsModel,
        );
      },
      child: Container(
        width: 358.w,
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.07),
              blurRadius: 16.w,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: ColorsManager.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: MySvg(
                      image: applicationType.icon,
                      width: 32.w,
                      height: 32.w,
                    ),
                  ),
                  horizontalSpace(8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyles.font16Black500Weight),
                      verticalSpace(4.w),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const MySvg(image: 'clock'),
                          horizontalSpace(4.w),
                          Text(
                            time.timeSinceNow(),
                            style: TextStyles.font10Dark400Grey400Weight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpace(12.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const MySvg(image: 'location-dark'),
                  horizontalSpace(4.w),
                  Text(location, style: TextStyles.font12Dark500400Weight),
                ],
              ),
              verticalSpace(12.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MySvg(image: 'riyal_new', width: 16.w, height: 16.w),
                  horizontalSpace(4.w),
                  Text(
                    '$lowestPrice - $highestPrice ',
                    style: TextStyles.font14PrimaryColor400Weight,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MySvg(image: 'ruler-primary', width: 16.w, height: 16.w),
                      horizontalSpace(4.w),
                      Text(
                        '$lowestArea - $highestArea م²',
                        style: TextStyles.font14PrimaryColor400Weight,
                      ),
                    ],
                  ),
                ],
              ),
              const MyDivider(indent: 0),
              RealStateApplicationUserSection(userType: propertyUserType),
            ],
          ),
        ),
      ),
    );
  }
}
