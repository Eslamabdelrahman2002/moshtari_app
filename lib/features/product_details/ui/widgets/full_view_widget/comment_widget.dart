// lib/features/product_details/ui/widgets/full_view_widget/comment_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentWidget extends StatelessWidget {
  final String userName;
  final String comment;
  final String? price; // السعر اختياري
  final DateTime? createdAt; // التاريخ اختياري
  final String? avatarUrl; // صورة المستخدم اختيارية

  const CommentWidget({
    super.key,
    required this.userName,
    required this.comment,
    this.price,
    this.createdAt,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());

    Widget buildPriceBadge() {
      if (price == null || price!.trim().isEmpty) {
        return const SizedBox.shrink(); // لا يعرض إذا كان null أو فارغ (مثل null في JSON)
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: ColorsManager.primary50,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Text(
              'يسوم $price', // يعرض "يسوم [قيمة offer_price]"
              style: TextStyles.font12Blue400Weight,
            ),
            horizontalSpace(4),
            const MySvg(image: 'saudi_riyal'),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16.r,
          // TODO: استخدم avatarUrl الحقيقي عند توفره
          backgroundImage: const AssetImage('assets/images/car_mock.png'),
        ),
        horizontalSpace(8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          userName,
                          style: TextStyles.font14Black500Weight,
                          overflow: TextOverflow.ellipsis,
                        ),
                        buildPriceBadge(),
                      ],
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {},
                    child: const MySvg(image: 'more_icon'),
                  ),
                ],
              ),
              verticalSpace(8),
              Container(
                padding: EdgeInsets.all(12.sp),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorsManager.dark50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  comment,
                  textAlign: TextAlign.right,
                  style: TextStyles.font12Black400Weight,
                ),
              ),
              verticalSpace(4),
              Row(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {},
                    child: const MySvg(image: 'reply'),
                  ),
                  horizontalSpace(12),
                  if (createdAt != null)
                    Text(
                      timeago.format(createdAt!, locale: 'ar'),
                      style: TextStyles.font10Dark600Grey400Weight,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}