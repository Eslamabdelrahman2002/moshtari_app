import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

class CarStepClassify extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController typeCtrl;
  final TextEditingController modelCtrl;
  final VoidCallback onAddThumb;
  final VoidCallback onAddImages;
  final VoidCallback onPickType;
  final VoidCallback onPickModel;
  final VoidCallback onNext;

  const CarStepClassify({
    super.key,
    required this.titleCtrl,
    required this.descCtrl,
    required this.typeCtrl,
    required this.modelCtrl,
    required this.onAddThumb,
    required this.onAddImages,
    required this.onPickType,
    required this.onPickModel,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _label('عنوان المزاد'),
        _textInput(
          titleCtrl,
          'حدد عنوان المزاد',
          suffix: MySvg(image: 'ic_info', width: 16.w, height: 16.h),
        ),
        SizedBox(height: 12.h),

        _label('وصف المزاد'),
        _textArea(descCtrl, 'اكتب وصف المزاد'),
        SizedBox(height: 16.h),

        _label('صورة مصغّرة للمزاد'),
        _dashed('إضافة صورة', onAddThumb),
        SizedBox(height: 12.h),

        _label('صور السيارة المراد المزايدة عليها'),
        _dashed('إضافة صورة', onAddImages),
        SizedBox(height: 12.h),

        _label('النوع'),
        _picker(typeCtrl, 'ادخل نوع السيارة', onPickType),
        SizedBox(height: 12.h),

        _label('الموديل'),
        _picker(modelCtrl, 'ادخل موديل السيارة', onPickModel),
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

  Widget _label(String t) =>
      Align(alignment: Alignment.centerRight, child: Text(t, style: TextStyles.font14Dark500Weight));

  InputDecoration _dec(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix == null
          ? null
          : Padding(
        padding: EdgeInsetsDirectional.only(end: 12.w),
        child: suffix,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorsManager.dark200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorsManager.dark200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorsManager.primary300),
      ),
    );
  }

  Widget _textInput(TextEditingController c, String hint, {Widget? suffix}) =>
      TextField(controller: c, decoration: _dec(hint, suffix: suffix));

  Widget _textArea(TextEditingController c, String hint) =>
      TextField(controller: c, minLines: 3, maxLines: 5, decoration: _dec(hint));

  Widget _picker(TextEditingController c, String hint, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _dec(hint, suffix: Icon(Icons.keyboard_arrow_down)),
        child: Text(
          c.text.isEmpty ? hint : c.text,
          style: c.text.isEmpty ? TextStyles.font14DarkGray400Weight : TextStyles.font14Black500Weight,
        ),
      ),
    );
  }

  Widget _dashed(String text, VoidCallback onTap) {
    return DottedBorder(
      color: ColorsManager.dark200,
      strokeWidth: 1.2,
      dashPattern: const [6, 4],
      borderType: BorderType.RRect,
      radius: Radius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 60.h,
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