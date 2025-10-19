import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class TechnicalInspectionFileUploader extends StatelessWidget {
  const TechnicalInspectionFileUploader({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: DottedBorder(
        radius: Radius.circular(10.r),
        borderType: BorderType.RRect,
        color: ColorsManager.primary200,
        dashPattern: const [10, 10],
        strokeWidth: 1,
        child: Container(
          width: 358.w,
          height: 127.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const MySvg(image: 'techincal_file'),
              Text(
                'إضافة ملف الفحص الفني',
                style: TextStyles.font12Primary300400Weight,
              ),
              Text(
                  'ندعم فقط الانواع التالية من الملفات: png, jpg, pdf\nويشترط على حجم الملف ان يكون اقل من 2:00 ميغا بايت',
                  style: TextStyles.font10DarkGray400Weight),
            ],
          ),
        ),
      ),
    );
  }
}
