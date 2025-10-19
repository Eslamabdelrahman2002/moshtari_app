import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/create_ad/ui/widgets/photo_video_item.dart';

class CreateRealEstateAdAddPhotoVideo extends StatelessWidget {
  final Future Function() pickImage;
  final List<File> pickedImages;
  final Function(int) remove;
  const CreateRealEstateAdAddPhotoVideo({
    super.key,
    required this.pickImage,
    required this.pickedImages,
    required this.remove,
  });

  @override
  Widget build(BuildContext context) {
    return pickedImages.isEmpty
        ? InkWell(
            onTap: () async {
              await pickImage();
            },
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 15.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const MySvg(image: 'add_photo_video'),
                    Text(
                      'إضافة صوره او مقطع فيديو',
                      style: TextStyles.font12Primary300400Weight,
                    ),
                    Text(
                        'ندعم فقط الانواع التالية من الصور والفيديو: png, jpg, mp4 \n ويشترط على حجم الملف ان يكون اقل من 2:00 ميغا بايت',
                        style: TextStyles.font10DarkGray400Weight),
                  ],
                ),
              ),
            ),
          )
        : Container(
            width: 358.w,
            // height: 137.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الصور ومقاطع الفيديو',
                      style: TextStyles.font16Black500Weight,
                    ),
                    DottedBorder(
                      radius: Radius.circular(10.r),
                      borderType: BorderType.RRect,
                      color: ColorsManager.primary200,
                      dashPattern: const [10, 10],
                      strokeWidth: 1,
                      child: MyButton(
                        height: 30.h,
                        minWidth: 108.w,
                        label: 'إضافة المزيد',
                        labelStyle: TextStyles.font12Primary300400Weight,
                        image: 'add_border',
                        iconHeight: 13.w,
                        iconWidth: 13.w,
                        radius: 10.r,
                        onPressed: () async {
                          await pickImage();
                        },
                      ),
                    ),
                  ],
                ),
                verticalSpace(12),
                SizedBox(
                  height: 150.w,
                  child: ListView.builder(
                      itemCount: pickedImages.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return FittedBox(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PhotoVideoItem(
                            imageFile: pickedImages[index],
                            remove: () {
                              remove(index);
                            },
                          ),
                        ));
                      }),
                ),
              ],
            ),
          );
  }
}
