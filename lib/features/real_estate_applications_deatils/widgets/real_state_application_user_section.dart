import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/enums.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealStateApplicationUserSection extends StatelessWidget {
  final RealStateUserTypes userType;
  const RealStateApplicationUserSection({
    super.key,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: ColorsManager.white,
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/prof.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        horizontalSpace(4.w),
        Text(
          'سامي محمد ابو المجد',
          style: TextStyles.font16Black500Weight,
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: ColorsManager.secondary50,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MySvg(image: userType.icon),
              horizontalSpace(4.w),
              Text(
                userType.name,
                style: TextStyles.font12secondary500yellow400Weight,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
