import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class RealEstateShowMore extends StatelessWidget {
  const RealEstateShowMore({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: InkWell(
          onTap: () {},
          highlightColor: ColorsManager.transparent,
          splashColor: ColorsManager.transparent,
          child: Text(
            '....  عرض المزيد',
            style: TextStyles.font14secondary600yellow400Weight,
          ),
        ),
      ),
    );
  }
}
