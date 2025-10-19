import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/electronics_segmented_info_panel.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';
import 'package:mushtary/features/create_ad/ui/widgets/secondary_text_form_field_has_value.dart';

class ElectronicsAdvancedDetailsScreen extends StatefulWidget {
  const ElectronicsAdvancedDetailsScreen({super.key});

  @override
  State<ElectronicsAdvancedDetailsScreen> createState() =>
      _ElectronicsAdvancedDetailsScreenState();
}

class _ElectronicsAdvancedDetailsScreenState
    extends State<ElectronicsAdvancedDetailsScreen> {
  bool isPriceAvailable = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const ElectronicsSegmentedInfoPanel(),
            DetailSelector(
              title: 'طريقه البيع',
              widget: Row(
                children: [
                  const Expanded(child: CustomizedChip(title: 'على السوم')),
                  horizontalSpace(16),
                  const Expanded(child: CustomizedChip(title: 'حد')),
                ],
              ),
            ),
            verticalSpace(16),
            SecondaryTextFormField(
              hint: 'سعر البيع',
              label: 'سعر البيع',
              maxheight: 48.h,
              minHeight: 48.h,
              isNumber: true,
            ),
            verticalSpace(16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    inactiveTrackColor: ColorsManager.lightGrey,
                    thumbColor: ColorsManager.secondary500,
                    activeTrackColor: ColorsManager.secondary200,
                    value: isPriceAvailable,
                    onChanged: (value) {
                      setState(() {
                        isPriceAvailable = value;
                      });
                    },
                  ),
                ),
                horizontalSpace(4),
                Text(
                  'السعر عند الاتصال',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: ColorsManager.darkGray600,
                  ),
                ),
              ],
            ),
            DetailSelector(
              title: 'طريقه البيع',
              widget: Row(
                children: [
                  const Expanded(child: CustomizedChip(title: 'جديد')),
                  horizontalSpace(16),
                  const Expanded(child: CustomizedChip(title: 'مستعمل')),
                ],
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
                label: 'سعة التخزين',
                hint: 'أختر سعة التخزين',
                maxheight: 56.h,
                minHeight: 56.h,
                suffexIcon: 'arrow-left',
                isEnabled: false,
              ),
            ),
            verticalSpace(16),
            SecondaryTextFormField(
              label: 'اللون',
              hint: 'أدخل اللون',
              maxheight: 56.h,
              minHeight: 56.h,
            ),
            verticalSpace(16),
            NextButtonBar(
              title: 'التالي',
              onPressed: () {},
            ),
            verticalSpace(16),
          ],
        ),
      ),
    );
  }
}
