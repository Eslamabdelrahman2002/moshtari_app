import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/features/create_ad/ui/widgets/file_name_chip.dart';

class CreateAdFile extends StatelessWidget {
  const CreateAdFile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      // height: 137.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الملفات المرفقة',
                style: TextStyles.font16Black500Weight,
              ),
              DottedBorder(
                radius: Radius.circular(10.r),
                borderType: BorderType.RRect,
                color: ColorsManager.primary200,
                dashPattern: const [10, 10],
                strokeWidth: 1,
                child: MyButton(
                  height: 30.h,
                  minWidth: 108.w,
                  label: 'إضافة المزيد',
                  labelStyle: TextStyles.font12Primary300400Weight,
                  image: 'add_border',
                  iconHeight: 13.w,
                  iconWidth: 13.w,
                  radius: 10.r,
                ),
              ),
            ],
          ),
          verticalSpace(12),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const FileNameChip(),
                  horizontalSpace(8),
                  const FileNameChip(),
                  horizontalSpace(8),
                  const FileNameChip(),
                  horizontalSpace(8),
                  const FileNameChip(),
                ],
              )),
        ],
      ),
    );
  }
}
