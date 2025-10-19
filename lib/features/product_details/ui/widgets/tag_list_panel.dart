import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';

class TagListPanel extends StatelessWidget {
  const TagListPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text('الكلمات الدلالية',
                style: TextStyles.font16Dark300Grey400Weight),
          ),
          verticalSpace(8),
          Row(
            children: [
              ...List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Chip(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: const BorderSide(color: ColorsManager.grey100),
                    ),
                    backgroundColor: ColorsManager.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    label: Text(
                      'كلمة دلالية',
                      style: TextStyles.font12Black400Weight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const MyDivider(),
        ],
      ),
    );
  }
}
