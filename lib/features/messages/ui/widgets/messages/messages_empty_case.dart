import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import '../../../../../core/router/routes.dart';

class MessagesEmptyCase extends StatelessWidget {
  const MessagesEmptyCase({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          const Spacer(),
          const MySvg(image: 'messages_empty'),
          verticalSpace(8),
          Text(
            'لم تقم بجراء اي محادثه حتي الان',
            style: TextStyles.font16Black500Weight,
          ),
          verticalSpace(8),
          Text(
            'قم بالتسوق والمحادثه مع التجار عندما تجد منتج يناسبك',
            style: TextStyles.font14Dark400400Weight,
          ),
          verticalSpace(32),
          PrimaryButton(
            text: 'الذهاب للاعلانات',
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.bottomNavigationBar);
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}