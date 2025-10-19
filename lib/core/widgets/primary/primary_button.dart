import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import '../../theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isIconButton;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double? height;
  final double? fontSize;
  final bool isOutlineButton;
  final bool isPrefixIconInCenter;
  final double? borderRadius;
  final FontWeight? fontWeight;
  final Color loadingProgressColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isIconButton = false,
    this.isDisabled = false,
    this.icon,
    this.backgroundColor,
    this.width,
    this.height,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.prefixIcon,
    this.suffixIcon,
    this.isOutlineButton = false,
    this.loadingProgressColor = Colors.white,
    this.isPrefixIconInCenter = false,
    this.borderRadius,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: setupButton(),
    );
  }

  ElevatedButton setupButton() {
    return ElevatedButton(
      onPressed: isDisabled
          ? null
          : () {
              if (!isLoading) {
                onPressed();
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? ColorsManager.darkGray
            : backgroundColor ?? ColorsManager.primaryColor,
        elevation: 0,
        side: isOutlineButton
            ? BorderSide(
                color: borderColor ?? ColorsManager.darkGray,
                width: 1,
              )
            : BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      child: setupButtonContent(),
    );
  }

  Row setupButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading && isIconButton)
          CupertinoActivityIndicator(
            color: loadingProgressColor,
          ),
        if (isIconButton) const Spacer(),
        prefixIcon ?? const SizedBox.shrink(),
        if (prefixIcon != null)
          isPrefixIconInCenter ? horizontalSpace(10) : const Spacer(),
        Text(
          text,
          style: TextStyle(
            fontWeight: fontWeight ?? FontWeight.w700,
            fontSize: fontSize,
            color: textColor ?? Colors.white,
          ),
        ),
        suffixIcon ?? const SizedBox.shrink(),
        if (prefixIcon != null && !isPrefixIconInCenter) const Spacer(),
        if (isLoading && !isIconButton)
          const SizedBox(
            width: 10,
          ),
        if (isLoading && !isIconButton)
          CupertinoActivityIndicator(
            color: loadingProgressColor,
          ),
        if (isIconButton) const Spacer(),
        if (isIconButton)
          Icon(
            icon,
            color: Colors.white,
          ),
      ],
    );
  }
}
