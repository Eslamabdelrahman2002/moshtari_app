import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../theme/text_styles.dart';

class SecondaryTextFormField extends StatelessWidget {
  final String? label;
  final String hint;
  final double maxheight;
  final double minHeight;
  final int? maxLines;
  final int? minLines;
  final bool? isEnabled;
  final TextEditingController? controller;
  final String? suffexIcon;
  final String? prefixIcon;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool isNumber;
  final bool isPhone;
  final int? maxLength;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;

  const SecondaryTextFormField({
    super.key,
    this.label,
    required this.hint,
    required this.maxheight,
    required this.minHeight,
    this.maxLines,
    this.minLines,
    this.isEnabled = true,
    this.controller,
    this.suffexIcon,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType,
    this.isNumber = false,
    this.isPhone = false,
    this.maxLength,
    this.onTap,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      onTap: onTap,
      readOnly: onTap != null,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      cursorColor: ColorsManager.black,
      decoration: setupTextFormFieldStyle(),
      onTapOutside: (event) {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      keyboardType: isNumber
          ? TextInputType.number
          : isPhone
          ? TextInputType.phone
          : keyboardType,
      inputFormatters:
      isNumber || isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
    );
  }

  InputDecoration setupTextFormFieldStyle() {
    // طبع القيود: تأكد أن maxheight ≥ minHeight دائماً
    double minH = minHeight;
    double maxH = maxheight;
    if (maxH < minH) {
      final tmp = maxH;
      maxH = minH;
      minH = tmp;
    }
    final bool isMultiline = (maxLines ?? 1) > 1;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      counterText: '',
      suffixIcon: suffexIcon != null
          ? Padding(
        padding: EdgeInsets.all(12.w),
        child: MySvg(image: suffexIcon!, width: 24.w, height: 24.w),
      )
          : null,
      prefixIcon: prefixIcon != null
          ? Padding(
        padding: EdgeInsets.all(12.w),
        child: MySvg(image: prefixIcon!, width: 16.w, height: 16.w),
      )
          : null,
      labelStyle: TextStyles.font12Dark500400Weight,
      hintStyle: TextStyles.font14Dark200400Weight,
      // لو متعدد الأسطر: لا نقيّد أقصى الارتفاع، بس نحافظ على حد أدنى
      constraints: isMultiline
          ? BoxConstraints(minHeight: minH)
          : BoxConstraints(minHeight: minH, maxHeight: maxH),
      isCollapsed: false,
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorsManager.dark200, strokeAlign: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorsManager.dark200, strokeAlign: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorsManager.primaryColor, strokeAlign: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
      ),
    );
  }
}