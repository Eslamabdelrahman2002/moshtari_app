import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/product_details/ui/widgets/stars_rate.dart';

class CurrentUserInfo extends StatelessWidget {
  final String ownerName;
  final String? ownerPicture;
  final bool isVerified;
  final double rating;     // تأكد أنه double
  final int reviewsCount;
  final VoidCallback? onFollow;

  const CurrentUserInfo({
    super.key,
    required this.ownerName,
    this.ownerPicture,
    this.isVerified = false,
    this.rating = 0,
    this.reviewsCount = 0,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final img = (ownerPicture != null && ownerPicture!.trim().isNotEmpty)
        ? ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        ownerPicture!,
        width: 40.w,
        height: 40.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/prof.png',
          width: 40.w,
          height: 40.w,
          fit: BoxFit.cover,
        ),
      ),
    )
        : ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.asset(
        'assets/images/prof.png',
        width: 40.w,
        height: 40.w,
        fit: BoxFit.cover,
      ),
    );

    return Container(
      width: 358.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: ColorsManager.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          img,
          horizontalSpace(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ownerName.isEmpty ? '—' : ownerName,
                        style: TextStyles.font14Black500Weight,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      horizontalSpace(8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: ColorsManager.lightTeal,
                          borderRadius: BorderRadius.circular(80.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('موثق', style: TextStyles.font12Green400Weight),
                            horizontalSpace(2),
                            Icon(Icons.verified, color: ColorsManager.teal, size: 12.w),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                verticalSpace(4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // تمرير double إلى StarsRate
                    StarsRate(rate: rating),
                    horizontalSpace(8),
                    Text(
                      '( ${reviewsCount.toString()} اراء )',
                      style: TextStyles.font10Dark400Grey400Weight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          MaterialButton(
            onPressed: onFollow,
            padding: EdgeInsets.zero,
            minWidth: 32.w,
            height: 32.h,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            color: ColorsManager.primary50,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            child: MySvg(image: 'user_add', width: 16.w, height: 16.h),
          ),
        ],
      ),
    );
  }
}