import 'package:flutter/material.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class MenuScreenAppBar extends StatelessWidget {
  const MenuScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
            },
            child: const MySvg(image: 'back_arrow'),
          ),
          const MySvg(image: 'logo_on_white', isImage: false),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              context.pushNamed(Routes.notificationsScreen);
            },
            child: const MySvg(image: 'notification'),
          ),
        ],
      ),
    );
  }
}
