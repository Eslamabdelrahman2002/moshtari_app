import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import '../widgets/auction_ui_parts.dart';
import '../widgets/auction_inputs.dart';

class RealEstateStepClassify extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final VoidCallback onAddThumb;
  final VoidCallback onAddImages;
  final VoidCallback onNext;
  final VoidCallback onPickType;
  final ValueChanged<String> onPurposeChange;
  final String estateTypeHint;
  final String purposeText; // 'إيجار' أو 'بيع'

  const RealEstateStepClassify({
    super.key,
    required this.titleCtrl,
    required this.descCtrl,
    required this.onAddThumb,
    required this.onAddImages,
    required this.onNext,
    required this.onPickType,
    required this.onPurposeChange,
    required this.estateTypeHint,
    required this.purposeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const AuctionStepperHeader(currentStep: 0),
        SizedBox(height: 16.h),

        _FieldContainer(
          child: TextField(
            controller: titleCtrl,
            decoration: _inputDecoration('حدد عنوان المزاد', suffix: MySvg(image: 'ic_info', width: 18.w, height: 18.h)),
          ),
          label: 'عنوان المزاد',
        ),
        SizedBox(height: 12.h),

        _FieldContainer(
          child: TextField(
            controller: descCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: _inputDecoration('اكتب وصف المزاد'),
          ),
          label: 'وصف المزاد',
        ),
        SizedBox(height: 16.h),

        Align(alignment: Alignment.centerRight, child: Text('صورة مصغرة للمزاد', style: TextStyles.font14Dark500Weight)),
        SizedBox(height: 8.h),
        _DashedBoxButton(text: 'إضافة صورة', onTap: onAddThumb),
        SizedBox(height: 12.h),

        Align(alignment: Alignment.centerRight, child: Text('صورة العقار', style: TextStyles.font14Dark500Weight)),
        SizedBox(height: 8.h),
        _DashedBoxButton(text: 'إضافة صورة', onTap: onAddImages),
        SizedBox(height: 12.h),

        _FieldContainer(
          child: InkWell(
            onTap: onPickType,
            child: InputDecorator(
              decoration: _inputDecoration('حدد نوع العقار', suffix: MySvg(image: 'ic_chevron_down', width: 16.w, height: 16.h)),
              child: Row(
                children: [
                  Text(
                    estateTypeHint.isEmpty ? 'حدد نوع العقار' : estateTypeHint,
                    style: estateTypeHint.isEmpty ? TextStyles.font14DarkGray400Weight : TextStyles.font14Black500Weight,
                  ),
                ],
              ),
            ),
          ),
          label: 'نوع العقار',
          
        ),
        SizedBox(height: 12.h),

        Align(alignment: Alignment.centerRight, child: Text('غرض الإعلان', style: TextStyles.font14Dark500Weight)),
        SizedBox(height: 8.h),
        SegmentedTwo(
          left: 'إيجار',
          right: 'بيع',
          selected: purposeText,
          onChange: onPurposeChange,
        ),

        SizedBox(height: 20.h),
        PrimaryButton(
          text: 'التالي',
          onPressed: onNext,
          backgroundColor: ColorsManager.primaryColor,
          borderRadius: 16,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix == null ? null : Padding(padding: EdgeInsetsDirectional.only(end: 12.w), child: suffix),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: ColorsManager.dark200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: ColorsManager.dark200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: ColorsManager.primary300)),
    );
  }
}

class _FieldContainer extends StatelessWidget {
  final Widget child;
  final String label;
  const _FieldContainer({required this.child, required this.label, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

class _DashedBoxButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _DashedBoxButton({required this.text, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: ColorsManager.dark200,
      strokeWidth: 1.2,
      dashPattern: const [6, 4],
      borderType: BorderType.RRect,
      radius: Radius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 60.h,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MySvg(image: 'gallery-add', width: 18.w, height: 18.h),
              SizedBox(width: 6.w),
              Text(text, style: TextStyles.font14Blue500Weight),
            ],
          ),
        ),
      ),
    );
  }
}