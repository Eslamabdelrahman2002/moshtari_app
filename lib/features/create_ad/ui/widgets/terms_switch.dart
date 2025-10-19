import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class TermsSwith extends StatelessWidget {
  final String lable;

  const TermsSwith({
    super.key,
    required this.lable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            value: false,
            inactiveTrackColor: ColorsManager.lightGrey,
            thumbColor: Colors.black.withOpacity(0.15),
            onChanged: (value) {},
          ),
        ),
        Text(
          lable,
          style: TextStyles.font16Dark400Weight,
        ),
      ],
    );
  }
}
