// lib/features/services/ui/widgets/dinat_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import 'dinat_trip_details_dialog.dart';

class DinatGridItem extends StatelessWidget {
  final String fromCity;
  final String toCity;
  final String sizeLabel; // مثال: كبيرة
  final String dateLabel; // مثال: الثلاثاء 12 مارس
  final String timeLabel; // مثال: 3:00 مساء
  final String userName; // مثال: عبدالرحمن علي
  final String userAvatar; // مثال: assets/images/prof.png
  final String mapImage; // مثال: assets/images/dinat_map.png
  final VoidCallback? onRequestTap;

  const DinatGridItem({
    super.key,
    this.fromCity = 'جدة',
    this.toCity = 'الرياض',
    this.sizeLabel = 'كبيرة',
    this.dateLabel = 'الثلاثاء 12 مارس',
    this.timeLabel = '3:00 مساء',
    this.userName = 'عبدالرحمن علي',
    this.userAvatar = 'assets/images/prof.png',
    this.mapImage = 'assets/images/map_image.png',
    this.onRequestTap,
  });
  void _showDetails(BuildContext context) {
    // يمكنك هنا استخراج البيانات الحقيقية من الـ item
    final details = DinatTripDetails(
      title: 'طلب نقل أثاث منزلي - من ${fromCity} إلى ${toCity}',
      pickUpAddress: fromCity,
      dropOffAddress: toCity,
      mapImage: mapImage,
    );

    showDialog(
      context: context,
      builder: (ctx) => DinatTripDetailsDialog(details: details),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 4,
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الصورة بالأعلى بعرض الكارت كله
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: Image.asset(
                  mapImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            verticalSpace(8),

            // العنوان: من ... إلى + أيقونة المسار
            Row(
              children: [
                Expanded(
                  child:  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyles.font14Black500Weight, // النمط الافتراضي
                      children: [
                        TextSpan(text: fromCity), // المدينة الأولى
                        TextSpan(
                          text: ' ---> ', // علامة المسار
                          style: TextStyles.font14Black500Weight.copyWith(
                            color: ColorsManager.primaryColor, // 💡 اللون الأساسي
                          ),
                        ),
                        TextSpan(text: toCity), // المدينة الثانية
                      ],
                    ),
                  ),
                ),
                // horizontalSpace(4), // تم تقليل المسافة
                // const MySvg(image: 'fromto'),
              ],
            ),
            verticalSpace(6),

            // السطر التفصيلي: الحجم
            Expanded(
              child: Row(
                children: [

                  MySvg(image: 'size', width: 12.w, height: 12.h),
                  horizontalSpace(4),
                  // وضع الحجم في Expanded ليكون مرناً
                  Text(
                    'سعة الحموله :',
                    style: TextStyles.font12DarkGray400Weight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$sizeLabel',
                    style: TextStyles.font12Black500Weight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            verticalSpace(4),

            // سطر التاريخ والوقت (تم إعادة هيكلته لحل مشكلة Overflow)
            Row(
              children: [
                // الجزء الأول: التاريخ
                Expanded(
                  child: Row(
                    children: [
                      MySvg(image: 'calendar', width: 16.w, height: 16.h),
                      horizontalSpace(4), // تم تقليل المسافة
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: TextStyles.font12Black500Weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                horizontalSpace(8),

                // الجزء الثاني: الوقت
                Expanded(
                  child: Row(
                    children: [
                      MySvg(image: 'clock', width: 16.w, height: 16.h),
                      horizontalSpace(4), // تم تقليل المسافة
                      Expanded(
                        child: Text(
                          timeLabel,
                          style: TextStyles.font12Black500Weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpace(8),

            // المستخدم
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundImage: AssetImage(userAvatar),
                ),
                horizontalSpace(6),
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyles.font12Black500Weight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                horizontalSpace(4),
                MySvg(image: 'judge', width: 16.w, height: 16.h),
              ],
            ),
            verticalSpace(10),

            // زر طلب خدمة
            PrimaryButton(
              height: 36.h,
              backgroundColor: ColorsManager.primary500,
              textColor: Colors.white,
              text: 'طلب خدمة',
              onPressed: ()=>_showDetails(context),
            ),
          ],
        ),
      ),
    );
  }
}