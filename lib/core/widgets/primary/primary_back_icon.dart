import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class PrimaryBackIcon extends StatelessWidget {
  final Color? color;
  const PrimaryBackIcon({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pop();
      },
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: RotatedBox(
            quarterTurns: context.locale == const Locale('ar') ? 0 : 2,
            child: MySvg(
                image: 'back_arrow',
                colorFilter: color != null
                    ? ColorFilter.mode(color ?? Colors.white, BlendMode.srcIn)
                    : null)),
      ),
    );
  }
}
