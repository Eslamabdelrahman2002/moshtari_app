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
      leading:  IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back_ios_new,
        color: ColorsManager.darkGray300,)),

      surfaceTintColor: ColorsManager.transparent,
      title: Row(
        children: [
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
