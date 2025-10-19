import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/empty.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';

class CreateAddRealEstateAdvancedDetailsOptionalDetails
    extends StatelessWidget {
  final double? containerHeight;
  final bool isVisable;
  final Function(Function) customSetState;
  const CreateAddRealEstateAdvancedDetailsOptionalDetails({
    super.key,
    required this.containerHeight,
    required this.isVisable,
    required this.customSetState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(),
      height: containerHeight,
      child: (isVisable)
          ? Column(
        children: [
          DetailSelector(
            title: 'الحالة',
            widget: Row(
              children: const [
                Expanded(child: CustomizedChip(title: 'جديد')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: 'مستعمل')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: 'تالف')),
              ],
            ),
          ),
          verticalSpace(16),
          DetailSelector(
            title: 'عدد غرف النوم',
            widget: Row(
              children: const [
                Expanded(child: CustomizedChip(title: '١')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٢')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٣')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٤')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٥')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٦')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٧+')),
              ],
            ),
          ),
          verticalSpace(16),
          DetailSelector(
            title: 'عدد دورات المياه',
            widget: Row(
              children: const [
                Expanded(child: CustomizedChip(title: '١')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٢')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٣')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٤')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٥')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٦')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٧+')),
              ],
            ),
          ),
          verticalSpace(16),
          DetailSelector(
            title: 'عدد الصالات و المجالس',
            widget: Row(
              children: const [
                Expanded(child: CustomizedChip(title: '١')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٢')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٣')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٤')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٥')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٦')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: '٧+')),
              ],
            ),
          ),
          verticalSpace(16),
          DetailSelector(
            title: 'الخدمات',
            widget: Row(
              children: const [
                Expanded(child: CustomizedChip(title: 'مياة')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: 'كهرباء')),
                SizedBox(width: 16),
                Expanded(child: CustomizedChip(title: 'صرف صحي')),
              ],
            ),
          ),
          verticalSpace(16),
          SecondaryTextFormField(
            label: 'عرض الشارع',
            hint: 'أختر عرض الشارع',
            maxheight: 56.h,
            minHeight: 56.h,
          ),
          verticalSpace(16),
          DetailSelector(
            title: 'الواجهة',
            widget: Row(
              children: const [
                Expanded(child: CustomizedChip(title: 'شمال')),
                SizedBox(width: 8),
                Expanded(child: CustomizedChip(title: 'جنوب')),
                SizedBox(width: 8),
                Expanded(child: CustomizedChip(title: 'شرق')),
                SizedBox(width: 8),
                Expanded(child: CustomizedChip(title: 'غرب')),
              ],
            ),
          ),
          verticalSpace(16),
        ],
      )
          : const Empty(),
    );
  }
}
