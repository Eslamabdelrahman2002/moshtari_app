import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import '../../../../core/widgets/primary/my_svg.dart';

class CreateAdAppBar extends StatelessWidget {
  final Function()? pop;
  const CreateAdAppBar({
    super.key,
    this.pop,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: ColorsManager.transparent,
      title: Row(
        children: [
          Visibility(
            visible: pop != null,
            child: InkWell(
              onTap: pop,
              child:Icon(Icons.arrow_forward_ios)
            ),
          ),
          horizontalSpace(8.w),
          Text(
            'إنشاء إعلان',
            style: TextStyles.font20Black500Weight,
          ),
        ],
      ),
      centerTitle:false,
    );
  }
}
