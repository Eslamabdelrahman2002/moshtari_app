// lib/features/services/ui/widgets/dinat_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import '../../data/model/dinat_trip.dart'; // DynaTrip
import 'dinat_trip_details_dialog.dart';   // DinatTripDetailsDialog.show(context, trip: ...)

class DinatGridItem extends StatelessWidget {
  final DynaTrip trip;

  // اختياري لو تحب تمرر أكشن مخصص عند الانضمام/المحادثة
  final VoidCallback? onJoin;
  final VoidCallback? onChat;

  const DinatGridItem({
    super.key,
    required this.trip,
    this.onJoin,
    this.onChat,
  });

  String _fmtDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void _openDetails(BuildContext context) {
    DinatTripDetailsDialog.show(
      context,
      trip: trip,
      onJoin: onJoin,
      onChat: onChat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dep = DateTime.tryParse(trip.departureDateIso)?.toLocal();
    final dateLabel = dep != null ? _fmtDate(dep) : '';
    final timeLabel = dep != null ? _fmtTime(dep) : '';
    final sizeLabel = trip.dynaCapacity;

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
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: Image.asset('assets/images/map_image.png', fit: BoxFit.cover),
              ),
            ),
            verticalSpace(8),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyles.font14Black500Weight,
                      children: [
                        TextSpan(text: trip.fromCityNameAr),
                        TextSpan(
                          text: ' ---> ',
                          style: TextStyles.font14Black500Weight.copyWith(color: ColorsManager.primaryColor),
                        ),
                        TextSpan(text: trip.toCityNameAr),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(6),
            Row(
              children: [
                MySvg(image: 'size', width: 12.w, height: 12.h),
                horizontalSpace(4),
                Text('سعة الحمولة: ', style: TextStyles.font12DarkGray400Weight),
                Expanded(
                  child: Text(sizeLabel, style: TextStyles.font12Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            verticalSpace(4),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      MySvg(image: 'calendar', width: 16.w, height: 16.h),
                      horizontalSpace(4),
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
                Expanded(
                  child: Row(
                    children: [
                      MySvg(image: 'clock', width: 16.w, height: 16.h),
                      horizontalSpace(4),
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
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundImage: (trip.providerImage.isNotEmpty)
                      ? NetworkImage(trip.providerImage)
                      : const AssetImage('assets/images/prof.png') as ImageProvider,
                ),
                horizontalSpace(6),
                Expanded(
                  child: Text(
                    trip.providerName,
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
            PrimaryButton(
              height: 36.h,
              backgroundColor: ColorsManager.primary500,
              textColor: Colors.white,
              text: 'طلب خدمة',
              onPressed: () => _openDetails(context), // يفتح الديالوج الجديد
            ),
          ],
        ),
      ),
    );
  }
}