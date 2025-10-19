import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';

class MyDivider extends StatelessWidget {
  final double? height;
  final double? indent;
  const MyDivider({super.key, this.height = 32, this.indent = 16});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: ColorsManager.lightGrey,
      thickness: 1,
      endIndent: indent,
      indent: indent,
      height: height,
    );
  }
}

class VDivider extends StatelessWidget {
  final double? height;
  const VDivider(
    this.height, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: height,
        width: 1,
        child: const Center(
          child: DecoratedBox(
              decoration: BoxDecoration(
            color: ColorsManager.lightGrey,
          )),
        ),
      ),
    );
  }
}
