import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstateAppBar extends StatelessWidget {
  const RealEstateAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const MySvg(
        image: 'realstate-logo',
        isImage: false,
      ),
    );
  }
}
