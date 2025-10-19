import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';

class RealEstateMapItemDetails extends StatelessWidget {
  const RealEstateMapItemDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 106.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شقه للبيع',
                  style: TextStyles.font14Black500Weight,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListViewItemDataWidget(
                          image: 'location-dark',
                          text: 'الرياض',
                          width: 12.w,
                          height: 12.h,
                        ),
                        verticalSpace(4),
                        ListViewItemDataWidget(
                          image: 'user',
                          text: 'اسم المستخدم',
                          width: 12.w,
                          height: 12.h,
                        ),
                      ],
                    ),
                    horizontalSpace(36),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListViewItemDataWidget(
                          image: 'riyal_black',
                          isColoredText: true,
                          text: '889,115',
                          width: 12.w,
                          height: 12.h,
                        ),
                        verticalSpace(4),
                        ListViewItemDataWidget(
                          image: 'clock',
                          text: '1 دقيقة',
                          width: 12.w,
                          height: 12.h,
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ColorsManager.dark50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          const MySvg(image: 'ruler'),
                          horizontalSpace(4),
                          Text('140م',
                              style: TextStyles.font10Dark400Grey400Weight),
                        ],
                      ),
                    ),
                    horizontalSpace(16),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorsManager.dark50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          const MySvg(image: 'bed'),
                          horizontalSpace(4),
                          Text('3 عرف',
                              style: TextStyles.font10Dark400Grey400Weight),
                        ],
                      ),
                    ),
                    horizontalSpace(16),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorsManager.dark50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          const MySvg(image: 'panio'),
                          horizontalSpace(4),
                          Text('2 حمام',
                              style: TextStyles.font10Dark400Grey400Weight),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl:
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSD_HkvN6KnBSBehEr9d0JT4trCDFM0WGSuTA&s',
                fit: BoxFit.cover,
                width: 102.w,
                height: 90.w,
              ),
            ),
          ],
        ));
  }
}
