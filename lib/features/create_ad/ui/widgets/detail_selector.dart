import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

class DetailSelector extends StatelessWidget {
  final String title;
  final Widget widget;
  const DetailSelector({
    super.key,
    required this.title,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Align(
        //     alignment: Alignment.centerRight,
        //     child: Text(title, style: TextStyles.font16Dark500400Weight)),
        verticalSpace(8),
        widget
      ],
    );
  }
}
