import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/ui/widgets/story_avater.dart';

class StoryAndTitleWidget extends StatelessWidget {
  final String title;
  const StoryAndTitleWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StoryAvater(),
        Container(
          constraints: BoxConstraints(maxWidth: 290.w),
          child: Text(
            title,
            style: TextStyles.font20Black500Weight,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
