// [اسم الملف غير متوفر، ولكن نفترض أنه RealEstateCurrentUserInfo.dart]

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_stars_rate.dart';

class RealEstateCurrentUserInfo extends StatelessWidget {
  final String ownerName;
  final String? ownerPicture;
  final String userTitle;
  final String defaultImage = 'assets/images/prof.png';

  final VoidCallback? onTap;
  final VoidCallback? onLicenseTap; // 🔹 جديد (اختياري لو حابب الزر يعمل حاجة مختلفة)

  const RealEstateCurrentUserInfo({
    super.key,
    required this.ownerName,
    this.ownerPicture,
    this.onTap,
    this.onLicenseTap,
    this.userTitle = 'وسيط عقاري',
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object> imageProvider = (ownerPicture != null && ownerPicture!.isNotEmpty)
        ? NetworkImage(ownerPicture!)
        : AssetImage(defaultImage) as ImageProvider<Object>;

    return Material(
      color: ColorsManager.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap, // ✅ هيشتغل على كل الكرت
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
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
              // صورة
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
                clipBehavior: Clip.antiAlias,
              ),
              horizontalSpace(8),
              // نصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ownerName,
                            style: TextStyles.font14Black500Weight,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        horizontalSpace(8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: ColorsManager.lightTeal,
                            borderRadius: BorderRadius.circular(80.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('موثق', style: TextStyles.font12Green400Weight),
                              horizontalSpace(2),
                              Icon(Icons.verified, color: ColorsManager.teal, size: 12.w),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(userTitle, style: TextStyles.font10Primary400Weight),
                    verticalSpace(4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const RealEstateStarsRate(rate: 3),
                        horizontalSpace(8),
                        Text('( 5 اراء )', style: TextStyles.font10Dark400Grey400Weight),
                      ],
                    ),
                  ],
                ),
              ),
              // زر اليمين
              TextButton.icon(
                onPressed: onLicenseTap ?? onTap, // ✅ الافتراضي يفتح بروفايل الناشر
                style: TextButton.styleFrom(
                  backgroundColor: ColorsManager.primary50,
                  minimumSize: Size(66.w, 24.h),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                icon: MySvg(image: 'checkmark-primary', width: 16.w, height: 16.h),
                label: Text('رخصة فال', style: TextStyles.font10Primary500Weight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}