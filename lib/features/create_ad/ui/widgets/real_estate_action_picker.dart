import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';

enum RealEstateActionType { ad, request }

class RealEstateActionPicker extends StatefulWidget {
  final ValueChanged<RealEstateActionType> onSelect;

  const RealEstateActionPicker({super.key, required this.onSelect});

  @override
  State<RealEstateActionPicker> createState() => _RealEstateActionPickerState();
}

class _RealEstateActionPickerState extends State<RealEstateActionPicker> {
  RealEstateActionType? selectedType = RealEstateActionType.ad; // الافتراضي هو إعلان

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('اختر نوع الإجراء العقاري', style: TextStyles.font18Black500Weight),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            verticalSpace(16),

            Row(
              children: [
                // 1. الإعلان عن عقار
                Expanded(
                  child: _buildOption(
                    context,
                    type: RealEstateActionType.ad,
                    label: 'الإعلان عن عقار',
                    icon: 'ad_real_state',
                  ),
                ),
                horizontalSpace(16),
                // 2. طلب عقار
                Expanded(
                  child: _buildOption(
                    context,
                    type: RealEstateActionType.request,
                    label: 'طلب عقار',
                    icon: 'create_real_state',
                  ),
                ),
              ],
            ),
            verticalSpace(24),

            // زر التالي
            MyButton(
              label: 'التالي',labelStyle: TextStyles.font16White500Weight,
              backgroundColor: selectedType != null ? ColorsManager.primaryColor : ColorsManager.darkGray300,
              onPressed: selectedType != null
                  ? () {
                Navigator.of(context).pop();
                widget.onSelect(selectedType!);
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, {
    required RealEstateActionType type,
    required String label,
    required String icon,
  }) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primary50 : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.dark200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? ColorsManager.primaryColor : ColorsManager.darkGray300,
                  size: 20.sp,
                ),
                const Spacer(),
              ],
            ),
            verticalSpace(8),
            MySvg(image: icon, width: 40.w, height: 40.w),
            verticalSpace(8),
            Text(label, style: TextStyles.font14Black500Weight),
          ],
        ),
      ),
    );
  }
}

Future<void> showRealEstateActionPicker(BuildContext context, ValueChanged<RealEstateActionType> onSelect) async {
  return showDialog(
    context: context,
    builder: (ctx) => RealEstateActionPicker(onSelect: onSelect),
  );
}