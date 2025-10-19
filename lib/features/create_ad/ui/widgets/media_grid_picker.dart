import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:path/path.dart' as p;

class MediaGridPicker extends StatelessWidget {
  final List<File> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxCount;
  final String? title;

  const MediaGridPicker({
    super.key,
    required this.files,
    required this.onAdd,
    required this.onRemove,
    this.maxCount = 10,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final canAddMore = files.length < maxCount;
    final gridItems = canAddMore ? files.length + 1 : files.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Row(
            children: [
              Text(title!, style: TextStyles.font16Black500Weight),
              const Spacer(),
              Text('${files.length}/$maxCount', style: TextStyles.font12Dark500400Weight),
            ],
          ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridItems == 0 ? 1 : gridItems,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.w,
            crossAxisSpacing: 8.w,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (files.isEmpty && canAddMore) {
              return _AddTile(onAdd: onAdd);
            }
            if (canAddMore && index == gridItems - 1) {
              return _AddTile(onAdd: onAdd);
            }
            final file = files[index];
            final ext = p.extension(file.path).toLowerCase();
            final isVideo = ['.mp4', '.mov', '.m4v', '.avi', '.webm'].contains(ext);

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    file,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isVideo)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: const MySvg(image: 'play'),
                    ),
                  ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: InkWell(
                    onTap: () => onRemove(index),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 14.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onAdd;
  const _AddTile({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: ColorsManager.primary200,
      strokeWidth: 1,
      dashPattern: const [6, 6],
      borderType: BorderType.RRect,
      radius: Radius.circular(10.r),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MySvg(image: 'add_photo_video'),
              SizedBox(height: 6.h),
              Text('إضافة صور/فيديو', style: TextStyles.font12Primary300400Weight),
            ],
          ),
        ),
      ),
    );
  }
}