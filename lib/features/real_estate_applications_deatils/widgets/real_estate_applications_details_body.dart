import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/enums.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import '../../../core/widgets/primary/my_divider.dart';

import 'package:mushtary/core/widgets/reminder.dart';
import 'package:mushtary/features/real_estate_applications_deatils/widgets/real_estate_applications_app_bar.dart';
import 'package:mushtary/features/real_estate_applications_deatils/widgets/real_estate_applications_details_panel.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_info_description.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_peoperty_info.dart';

import '../../real_estate/data/model/mock_data.dart';
import 'real_estate_applications_current_user_info.dart';
import 'real_estate_applications_map_view.dart';
import 'real_estate_applications_similar_ads.dart';

class RealEstateApplicationsDetailsBody extends StatelessWidget {
  final RealStateApplicationsDetailsModel realStateApplicationsDetailsModel;
  const RealEstateApplicationsDetailsBody(
      {super.key, required this.realStateApplicationsDetailsModel});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const RealEstateApplicationsAppBar(),
            SizedBox(
              height: 285.w,
              child: const RealEstateApplicationsMapView(),
            ),
            RealEstateApplicationsDetailsPanel(
              time:
              realStateApplicationsDetailsModel.createdAt ?? DateTime.now(),
              title: realStateApplicationsDetailsModel.title ?? '',
              // Corrected the incorrect property access from '.location.address' to just '.location'.
              location:
              realStateApplicationsDetailsModel.location ?? '',
            ),
            const MyDivider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('تفاصيل الطلب',
                        style: TextStyles.font16Dark300Grey400Weight),
                  ),
                  verticalSpace(16),
                  RealEstatePropertyInfo(
                    data: {
                      'السعر':
                      '${realStateApplicationsDetailsModel.lowestPrice ?? ''} - ${realStateApplicationsDetailsModel.highestPrice ?? ''}',
                      'صفة مقدم الطلب':
                      realStateApplicationsDetailsModel.propertyUserType!.name,
                      'المساحة':
                      '${realStateApplicationsDetailsModel.lowestArea ?? ''} م2 - ${realStateApplicationsDetailsModel.highestArea ?? ''} م2',
                      'عرض الشارع':
                      '${realStateApplicationsDetailsModel.streetWidth} متر',
                      'عدد الادوار المسموح بها:':
                      '${realStateApplicationsDetailsModel.numberOfFloors} أدوار',
                      'رقم الطلب': realStateApplicationsDetailsModel.orderNumber
                          ?.toString() ??
                          '',
                      'طريقة الدفع':
                      realStateApplicationsDetailsModel.paymentMethod!.name,
                    },
                  ),
                ],
              ),
            ),
            RealEstateInfoDescription(
              description: realStateApplicationsDetailsModel.description ?? '',
            ),
            const MyDivider(),
            const RealEstateApplicationsCurrentUserInfo(),
            verticalSpace(20),
            const Reminder(),
            const MyDivider(),
            const RealEstateApplicationsSimilarAds()
          ],
        ),
      ),
    );
  }
}
