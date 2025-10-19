import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstateItemDatails extends StatelessWidget {
  final String image;
  final String text;
  final bool isColoredText;
  final double? width;
  final double? height;
  const RealEstateItemDatails(
      {super.key,
      required this.image,
      required this.text,
      this.isColoredText = false,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MySvg(image: image, width: width, height: height),
        horizontalSpace(2),
        Text(
          text,
          style: isColoredText
              ? TextStyles.font10Yellow500Weight
              : TextStyles.font14Dark400400Weight,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
