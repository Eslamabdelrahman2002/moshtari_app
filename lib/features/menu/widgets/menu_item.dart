import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class MenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final Widget? trailing;
  final Function onTap;
  final bool isHasTrailing;
  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.isHasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Row(
        children: [
          MySvg(image: icon,color: ColorsManager.darkGray300,),
          horizontalSpace(6),
          Text(title, style: TextStyles.font16DarkGrey400Weight),
          if (isHasTrailing) ...{const Spacer(), trailing!},
        ],
      ),
    );
  }
}
