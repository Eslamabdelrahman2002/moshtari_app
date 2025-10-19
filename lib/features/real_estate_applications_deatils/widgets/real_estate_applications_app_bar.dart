import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstateApplicationsAppBar extends StatelessWidget {
  const RealEstateApplicationsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
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
      child: Row(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              context.pop();
            },
            child: MySvg(
              image: 'arrow-down',
              rotate: true,
              rotationValue: 135,
              width: 24.w,
              height: 24.w,
            ),
          ),
          const Spacer(),
          const MySvg(
            image: 'realstate-logo',
            isImage: false,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
