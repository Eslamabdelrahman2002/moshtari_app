import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavBarItem {
  static SalomonBottomBarItem salamonBottomBarItem(String image, String text) {
    return SalomonBottomBarItem(
      icon: MySvg(image: image),
      title: Text(
        text,
        style: TextStyles.font10Primary500Weight,
      ),
      selectedColor: ColorsManager.secondary500,
    );
  }
}
