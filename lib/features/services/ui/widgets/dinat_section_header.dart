// features/services/ui/widgets/dinat_section_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class DinatSectionHeader extends StatelessWidget {
  final VoidCallback? onTap;

  const DinatSectionHeader({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            height: 70,
            color: ColorsManager.white,
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,color: ColorsManager.darkGray300,),
                Spacer(),
                Text('طلب الانضمام إلى رحلة حالية', style: TextStyles.font20Black500Weight),
                Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}