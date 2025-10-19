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
  // ✅ إضافة خاصية الوصف مع قيمة افتراضية
  final String userTitle;
  final String defaultImage = 'assets/images/prof.png';

  const RealEstateCurrentUserInfo({
    super.key,
    required this.ownerName,
    this.ownerPicture,
    // ✅ تعيين القيمة الافتراضية
    this.userTitle = 'وسيط عقاري',
  });

  @override
  Widget build(BuildContext context) {
    // تحديد مصدر الصورة إما من الشبكة أو من الأصول المحلية (Asset)
    final ImageProvider<Object> imageProvider = (ownerPicture != null && ownerPicture!.isNotEmpty)
        ? NetworkImage(ownerPicture!)
        : AssetImage(defaultImage) as ImageProvider<Object>;

    return Container(
      width: double.infinity,
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
          ]),
      child: Row(
        children: [
          // صورة المالك (تستخدم إما صورة الشبكة أو الصورة المحلية)
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                // يمكنك إضافة onError هنا للتعامل مع صور الشبكة الفاشلة
              ),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          horizontalSpace(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // ✅ استخدام ownerName بدلاً من 'اسم المستخدم' الثابت
                  Text(
                    ownerName,
                    style: TextStyles.font14Black500Weight,
                  ),
                  horizontalSpace(8),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: ColorsManager.lightTeal,
                      borderRadius: BorderRadius.circular(80.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'موثق',
                          style: TextStyles.font12Green400Weight,
                        ),
                        horizontalSpace(2),
                        Icon(
                          Icons.verified,
                          color: ColorsManager.teal,
                          size: 12.w,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              // ✅ استخدام الخاصية الجديدة userTitle
              Text(userTitle, style: TextStyles.font10Primary400Weight),
              verticalSpace(4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const RealEstateStarsRate(rate: 3),
                  horizontalSpace(8),
                  Text('( 5 اراء )',
                      style: TextStyles.font10Dark400Grey400Weight),
                ],
              ),
            ],
          ),
          const Spacer(),
          MaterialButton(
            onPressed: () {},
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
            minWidth: 66.w,
            height: 24.h,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            color: ColorsManager.primary50,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            child: Row(
              children: [
                Text(
                  'رخصة فال', // قد تحتاج أيضاً لتبديل هذا النص إذا كان خاصًا بالعقارات
                  style: TextStyles.font10Primary500Weight,
                ),
                horizontalSpace(2),
                MySvg(
                  image: 'checkmark-primary',
                  width: 16.w,
                  height: 16.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}