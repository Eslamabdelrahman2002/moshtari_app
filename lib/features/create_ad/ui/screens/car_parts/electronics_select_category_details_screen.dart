import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/secondary_text_form_field_has_value.dart';

class ElectronicsSelectCategoryDetailsScreen extends StatefulWidget {
  const ElectronicsSelectCategoryDetailsScreen({super.key});

  @override
  State<ElectronicsSelectCategoryDetailsScreen> createState() =>
      _ElectronicsSelectCategoryDetailsScreenState();
}

class _ElectronicsSelectCategoryDetailsScreenState
    extends State<ElectronicsSelectCategoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            InkWell(
              onTap: () {},
              child: SecondaryTextFormField(
                label: 'نوع الجهاز',
                hint: 'أختر نوع الجهاز',
                maxheight: 56.h,
                minHeight: 56.h,
                suffexIcon: 'arrow-left',
                isEnabled: false,
              ),
            ),
            verticalSpace(16),
            InkWell(
              onTap: () {},
              child: SecondaryTextFormField(
                label: 'الشركه',
                hint: 'اختر الشركه',
                maxheight: 56.h,
                minHeight: 56.h,
                suffexIcon: 'arrow-left',
                isEnabled: false,
              ),
            ),
            verticalSpace(16),
            InkWell(
              onTap: () {},
              child: SecondaryTextFormField(
                label: 'الموديل',
                hint: ' أدخل الموديل',
                maxheight: 56.h,
                minHeight: 56.h,
                suffexIcon: 'arrow-left',
                isEnabled: false,
              ),
            ),
            verticalSpace(16),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  barrierColor: ColorsManager.black.withOpacity(0.8),
                  context: context,
                  backgroundColor: ColorsManager.white,
                  elevation: 1,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) =>
                      SizedBox(height: 0.85.sh, child: Container()),
                );
              },
              child: SecondaryTextFormField(
                label: 'المدينه',
                hint: 'أختر المدينه',
                maxheight: 56.h,
                minHeight: 56.h,
                suffexIcon: 'arrow-left',
                isEnabled: false,
              ),
            ),
            verticalSpace(16),
            InkWell(
              onTap: () {},
              child: SecondaryTextFormField(
                label: 'الحي',
                hint: 'أختر الحي',
                maxheight: 56.h,
                minHeight: 56.h,
                suffexIcon: 'arrow-left',
                isEnabled: false,
              ),
            ),
            verticalSpace(16),
          ],
        ),
      ),
    );
  }
}
