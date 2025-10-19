import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/widgets/show_more.dart';

class InfoDescription extends StatelessWidget {
  final String description;
  const InfoDescription({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('الوصف', style: TextStyles.font16Dark300Grey400Weight),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Text(
              description,
              style: TextStyles.font14Black500Weight,
            ),
          ),
        ),
        verticalSpace(16),
        ShowMore(
          onTap: () {},
        ),
      ],
    );
  }
}
