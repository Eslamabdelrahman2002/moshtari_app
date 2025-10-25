import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkerListViewItem extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String rating;
  final String jobTitle;
  final String worksCountText;
  final String cityName;
  final String nationality;
  final int providerId;

  const WorkerListViewItem({
    super.key,
    required this.name,
    this.imageUrl,
    this.rating = '0.0',
    required this.jobTitle,
    required this.worksCountText,
    required this.cityName,
    required this.nationality,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final goDetails = () => context.pushNamed(Routes.workerDetailsScreen, arguments: providerId);
    final displayJobTitle = jobTitle.isEmpty ? 'غير محدد' : jobTitle;
    final imageHeight = 0.33.sw * 1.075;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), spreadRadius: 4, blurRadius: 7, offset: const Offset(0, 4))],
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة
          Expanded(
            flex: 4,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
              child: Stack(
                children: [
                  InkWell(
                    onTap: goDetails,
                    child: imageUrl == null || imageUrl!.isEmpty
                        ? Container(
                      height: imageHeight,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.person, size: 36)),
                    )
                        : CachedNetworkImage(
                      height: imageHeight,
                      fit: BoxFit.cover,
                      imageUrl: imageUrl!,
                      placeholder: (_, __) => Skeletonizer(
                        enabled: true,
                        child: Container(
                          height: imageHeight,
                          color: ColorsManager.grey200,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: imageHeight,
                        color: ColorsManager.grey200,
                        child: const Icon(Icons.person_off_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                  // التقييم
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
                      decoration: BoxDecoration(color: ColorsManager.secondary, borderRadius: BorderRadius.circular(4.r)),
                      child: Row(
                        children: [
                          Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(rating, style: TextStyles.font10White500Weight)),
                          horizontalSpace(4),
                          MySvg(image: 'white-star', width: 12.w, height: 12.w),
                        ],
                      ),
                    ),
                  ),
                  // مفضلة
                  Positioned(top: 8, right: 8, child: InkWell(child: MySvg(image: 'heart', width: 20.w, height: 20.h))),
                ],
              ),
            ),
          ),
          horizontalSpace(12),

          // التفاصيل
          Expanded(
            flex: 7,
            child: SizedBox(
              height: imageHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyles.font14Black500Weight,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  verticalSpace(4),

                  InkWell(
                    onTap: goDetails,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              MySvg(image: 'element-equal', width: 16.w, height: 16.h),
                              horizontalSpace(8),
                              Expanded(
                                child: Text(
                                  displayJobTitle,
                                  style: TextStyles.font12Black500Weight,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ]),
                          ),
                          horizontalSpace(8),
                          Expanded(
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              MySvg(image: 'clock', width: 16.w, height: 16.h),
                              horizontalSpace(8),
                              Expanded(
                                child: Text(
                                  worksCountText,
                                  style: TextStyles.font12Black500Weight,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ]),
                          ),
                        ]),
                        verticalSpace(8),
                        Row(children: [
                          Expanded(
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              MySvg(image: 'location-dark', width: 16.w, height: 16.h),
                              horizontalSpace(8),
                              Expanded(
                                child: Text(
                                  cityName,
                                  style: TextStyles.font12Black500Weight,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ]),
                          ),
                          horizontalSpace(8),
                          Expanded(
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              MySvg(image: 'user', width: 16.w, height: 16.h),
                              horizontalSpace(8),
                              Expanded(
                                child: Text(
                                  nationality,
                                  style: TextStyles.font12Black500Weight,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ],
                    ),
                  ),

                  const Spacer(),
                  MyButton(
                    onPressed: goDetails,
                    label: 'عرض التفاصيل',
                    backgroundColor: ColorsManager.primary50,
                    radius: 8.r,
                    textColor: ColorsManager.primaryColor,
                    labelStyle: TextStyles.font14Primary500Weight,
                    height: 32.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}