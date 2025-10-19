import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class NotificationsEmptyWidget extends StatelessWidget {
  const NotificationsEmptyWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const MySvg(image: 'notifications_empty'),
        verticalSpace(10),
        Text(
          'لا توجد إشعارات',
          style: TextStyles.font16Black500Weight,
        ),
        verticalSpace(8),
        Text(
          'جماعي موريس موريس يخشى هوية موريس هوية',
          style: TextStyles.font14DarkGray400Weight,
        ),
        const Spacer(),
      ],
    );
  }
}
