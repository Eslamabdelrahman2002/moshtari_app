import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ProductInfoItem extends StatelessWidget {
  final String title;
  final String icon;
  const ProductInfoItem(
      {super.key, this.title = 'اوتوماتك', this.icon = 'add'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MySvg(
            image: icon,
            width: 16.w,
            height: 16.h,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 90.w),
            child: Text(
              title,
              style: TextStyles.font12Black400Weight,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
