import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../data/model/real_estate_request_details_model.dart'; // استيراد موديل المستخدم

class RequestOwnerCard extends StatelessWidget {
  final RequestUserModel user;
  final bool isSeeker; // لتقرير ما إذا كانت الشارة "باحث عن عقار" ستظهر

  const RequestOwnerCard({
    super.key,
    required this.user,
    this.isSeeker = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 1. الشارة (badge)
            if (isSeeker)


            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ColorsManager.darkGray300, width: 1),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.profilePictureUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 28),
                ),
              ),
            ),
            horizontalSpace(12),
            Text(
              user.username ?? 'N/A',
              style: TextStyles.font16Black500Weight,
            ),

            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ColorsManager.primary50, // خلفية صفراء فاتحة
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: ColorsManager.primary200, width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    'باحث عن عقار',
                    style: TextStyles.font12Primary400400Weight,
                  ),
                  horizontalSpace(4),
                  const Icon(Icons.language, size: 14, color: ColorsManager.primary500), // أيقونة الكرة الأرضية
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}