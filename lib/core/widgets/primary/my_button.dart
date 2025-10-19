import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/empty.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class MyButton extends StatelessWidget {
  final Function()? onPressed;
  final Function()? onLongPress;
  final ButtonTextTheme? textTheme;
  final String? image;
  final String? label;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final double elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final double? disabledElevation;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final double? radius;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Duration? animationDuration;
  final double? minWidth;
  final double? height;
  final double stroke;
  final Color borderColor;
  final double gap;
  final TextStyle? labelStyle;
  final bool isImage;
  final String? imageIcon;
  final double? iconHeight;
  final double? iconWidth;
  final double? margin;

  const MyButton({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.textTheme,
    this.image,
    this.label,
    this.textColor,
    this.disabledTextColor,
    this.backgroundColor,
    this.disabledColor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.elevation = 0,
    this.focusElevation = 0,
    this.hoverElevation = 0,
    this.highlightElevation = 0,
    this.disabledElevation = 0,
    this.padding = EdgeInsets.zero,
    this.visualDensity,
    this.radius,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.animationDuration,
    this.minWidth,
    this.height,
    this.stroke = 0,
    this.borderColor = ColorsManager.transparent,
    this.gap = 8,
    this.labelStyle,
    this.isImage = false,
    this.imageIcon,
    this.iconHeight,
    this.iconWidth,
    this.margin = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: margin ?? 0),
      child: SizedBox(
        height: height,
        width: minWidth,
        child: MaterialButton(
          onPressed: () {
            if (onPressed != null) {
              onPressed!();
            }
          },
          onLongPress: onLongPress,
          textTheme: textTheme,
          textColor: textColor,
          disabledTextColor: disabledTextColor,
          color: backgroundColor,
          disabledColor: disabledColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          elevation: elevation,
          focusElevation: focusElevation,
          hoverElevation: hoverElevation,
          highlightElevation: highlightElevation,
          disabledElevation: disabledElevation,
          padding: padding,
          visualDensity: visualDensity,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 0),
            side: BorderSide(
                color: borderColor,
                strokeAlign: BorderSide.strokeAlignInside,
                width: stroke),
          ),
          clipBehavior: clipBehavior,
          focusNode: focusNode,
          autofocus: autofocus,
          materialTapTargetSize: materialTapTargetSize,
          animationDuration: animationDuration,
          minWidth: minWidth,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imageIcon != null
                  ? Image.asset(
                      'assets/images/$imageIcon.png',
                      width: iconWidth,
                      height: iconHeight,
                    )
                  : const Empty(),
              image != null
                  ? MySvg(
                      image: image!,
                      isImage: isImage,
                      height: iconHeight,
                      width: iconWidth,
                    )
                  : const Empty(),
              (image != null && label != null)
                  ? horizontalSpace(gap)
                  : const Empty(),
              label != null
                  ? Text(
                      label!,
                      style: labelStyle,
                    )
                  : const Empty(),
            ],
          ),
        ),
      ),
    );
  }
}
