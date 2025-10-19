// lib/features/services/ui/widgets/register_service_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/features/services/ui/widgets/bottom_sheet_item.dart';

class RegisterServiceBottomSheet extends StatelessWidget {
  const RegisterServiceBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'الخدمات',
                style: TextStyles.font20Black500Weight,
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 1.4,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
              mainAxisSpacing: 16.w,
              crossAxisSpacing: 16.w,
              children: [
                BottomSheetItem(
                  image: 'worker',
                  title: 'اجير',
                  onTap: () {
                    // navigate to the General/Worker flow
                    context.pop(result: Routes.completeProfileSteps);
                  },
                ),
                BottomSheetItem(
                  image: 'dinat',
                  title: 'دينات',
                  onTap: () {
                    // navigate to the Transport flow
                    context.pop(result: Routes.transportServiceSteps);
                  },
                ),
                BottomSheetItem(
                  image: 'satha',
                  title: 'سطحة',
                  onTap: () {
                    // navigate to the Delivery/Satha flow
                    context.pop(result: Routes.deliveryServiceSteps);
                  },
                ),
                BottomSheetItem(
                  image: 'shrej',
                  title: 'صهريج',
                  onTap: () {
                    // navigate to the Tanker flow
                    context.pop(result: Routes.tankerServiceSteps);
                  },
                ),
              ],
            ),
            verticalSpace(16),
            MyButton(
              label: 'صفحة خدماتي',
              labelStyle: TextStyles.font16Black500Weight,
              onPressed: () {},
              backgroundColor: ColorsManager.primary50,
              height: 59.w,
              borderColor: ColorsManager.primaryColor, // Use primaryColor for border
              radius: 16.r,
              margin: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}