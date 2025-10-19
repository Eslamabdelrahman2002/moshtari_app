import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/colors.dart';
import '../../theme/fonts.dart';

class AuthTextFormField extends StatelessWidget {
  final String validationError;
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isPassword;
  final GestureTapCallback? onTap;
  final bool enabled;
  final String? initialValue;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool infiniteLines;
  final bool isValidate;
  final Function(String)? onChange;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Function(String?)? validator;
  final bool isAutoValidate;
  final bool isReadOnly;
  final Color? fillColor;

  const AuthTextFormField({
    super.key,
    required this.validationError,
    this.label,
    this.hint,
    this.controller,
    this.onFieldSubmitted,
    this.isPassword = false,
    this.onTap,
    this.initialValue,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.infiniteLines = false,
    this.isValidate = true,
    this.onChange,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
    this.isAutoValidate = false,
    this.isReadOnly = false,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      onTap: onTap,
      readOnly: isReadOnly,
      obscuringCharacter: '*',
      cursorColor: ColorsManager.black,
      autovalidateMode: isAutoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: isValidate
          ? (value) {
              if (validator != null) {
                return validator!(value);
              }
              if (value!.isEmpty) {
                return validationError;
              }
              return null;
            }
          : null,
      controller: controller,
      obscureText: isPassword,
      maxLines: infiniteLines ? null : 1,
      keyboardType: keyboardType,
      onChanged: onChange,
      onTapOutside: (event) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      decoration: setupTextFormFieldStyle(),
    );
  }

  InputDecoration setupTextFormFieldStyle() {
    return InputDecoration(
      labelStyle: const TextStyle(
        fontSize: 12,
        fontFamily: appArabicFontFamily,
        color: ColorsManager.textFormLableBlackColor,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      isDense: true,
      labelText: label,
      hintText: hint,
      filled: fillColor != null,
      fillColor: fillColor ?? ColorsManager.transparent,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: ColorsManager.fontLightGrey,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 3,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorsManager.lightGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: ColorsManager.lightGrey,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorsManager.lightGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: ColorsManager.lightGrey,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
