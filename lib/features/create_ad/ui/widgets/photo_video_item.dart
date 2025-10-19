import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:path/path.dart' as p;

class PhotoVideoItem extends StatelessWidget {
  final File imageFile;
  final Function remove;
  const PhotoVideoItem({
    super.key,
    required this.imageFile,
    required this.remove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.r,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: ColorsManager.dark50,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            clipBehavior: Clip.hardEdge,
            child: Image.file(
              imageFile,
              width: 104.r,
              height: 81.r,
              fit: BoxFit.cover,
            ),
          ),
          verticalSpace(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 50.w,
                child: Text(
                  p.basename(imageFile.path),
                  style: TextStyles.font12Black500Weight,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () {
                  remove();
                },
                child: MySvg(
                  image: 'close-square',
                  rotate: true,
                  rotationValue: 45,
                  width: 12.r,
                  height: 12.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
