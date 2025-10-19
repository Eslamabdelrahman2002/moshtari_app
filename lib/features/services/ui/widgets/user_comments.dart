import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../../service_profile/data/model/service_provider_models.dart'; // import لـ ProviderComment

class UserComments extends StatelessWidget {
  final List<ProviderComment> comments; // من provider.comments (ديناميكي)

  const UserComments({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 190.w,
        width: 1.sw,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Text(
                    'آراء العملاء',
                    style: TextStyles.font16DarkGrey500Weight,
                  ),
                  horizontalSpace(8),
                  Text(
                    '(${comments.length})', // ديناميكي بناءً على طول الـ list
                    style: TextStyles.font16Black500Weight,
                  ),
                ],
              ),
            ),
            verticalSpace(8),
            Expanded(
              flex: 4,
              child: comments.isEmpty
                  ?  Center(child: Text('لا توجد تعليقات', style: TextStyles.font14Black500Weight)) // handling empty
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length, // ديناميكي
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Container(
                    width: 0.7.sw,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorsManager.dark50,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999.r),
                                    child: CachedNetworkImage(
                                      imageUrl: comment.user.personalImage ?? '', // ديناميكي
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => const Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                horizontalSpace(8),
                                Text(
                                  comment.user.name, // ديناميكي
                                  style: TextStyles.font14Black500Weight,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              decoration: BoxDecoration(
                                color: ColorsManager.secondary500,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '4.7', // يمكن جعله ديناميكي إذا كان rating في comment
                                    style: TextStyles.font12White400Weight.copyWith(height: 0.1),
                                  ),
                                  horizontalSpace(4),
                                  MySvg(
                                    image: 'white-star',
                                    width: 10.w,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(16),
                        Text(
                          comment.comment, // ديناميكي
                          style: TextStyles.font14Black500Weight,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}