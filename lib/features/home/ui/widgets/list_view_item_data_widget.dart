import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ListViewItemDataWidget extends StatelessWidget {
  final String image;
  final String text;
  final bool isColoredText;
  final double? width;
  final double? height;
  const ListViewItemDataWidget(
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
      children: [
        MySvg(image: image, width: width, height: height),
        horizontalSpace(2),
        // ✨ FIX: Wrapped the Text widget with Flexible to prevent overflow
        Flexible(
          child: Text(
            text,
            style: isColoredText
                ? TextStyles.font10Yellow500Weight
                : TextStyles.font10DarkGray400Weight,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}