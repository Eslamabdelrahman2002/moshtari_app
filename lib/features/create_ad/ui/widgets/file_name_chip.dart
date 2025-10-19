import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class FileNameChip extends StatelessWidget {
  const FileNameChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: ColorsManager.dark50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'file_name.pdf',
            style: TextStyles.font12Black500Weight,
            overflow: TextOverflow.ellipsis,
          ),
          InkWell(
            onTap: () {
              const PopupMenuItem(
                child: Text('Delete'),
              );
            },
            child: MySvg(
              image: 'more',
              rotate: true,
              rotationValue: 45,
              width: 12.r,
              height: 12.r,
            ),
          ),
        ],
      ),
    );
  }
}
