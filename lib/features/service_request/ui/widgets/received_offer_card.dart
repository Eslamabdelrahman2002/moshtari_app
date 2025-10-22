import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import '../../data/model/received_offer_models.dart';

class ReceivedOfferCard extends StatelessWidget {
  final ReceivedOffer offer;
  final VoidCallback? onAccept;
  final bool isAccepting;
  final VoidCallback? onTap;

  const ReceivedOfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.onAccept,
    this.isAccepting = false,
  });

  Color _offerStatusColor(String s) {
    switch (s) {
      case 'accepted':
        return ColorsManager.success500;
      case 'rejected':
        return ColorsManager.errorColor;
      default: // pending
        return ColorsManager.secondary500;
    }
  }

  Color _requestStatusColor(String s) {
    switch (s) {
      case 'completed':
        return ColorsManager.success500;
      case 'in_progress':
        return ColorsManager.primaryColor;
      default: // pending/rejected
        return ColorsManager.darkGray;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'مقترح';
    }
  }

  String _reqLabel(String s) {
    switch (s) {
      case 'completed':
        return 'تم الانتهاء';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'بانتظار الموافقة';
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'dyna':
        return 'دينّا';
      case 'flatbed':
        return 'سطحة';
      case 'tanker':
        return 'صهريج';
      default:
        return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dfTime = DateFormat('HH:mm');
    final dfDate = DateFormat('dd/MM/yyyy');
    final canAccept = offer.status != 'accepted';

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. الصف العلوي (الاسم، السعر، حالة العرض)
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: ColorsManager.primary50,
                  backgroundImage: (offer.personalImage?.isNotEmpty == true)
                      ? CachedNetworkImageProvider(offer.personalImage!)
                      : null,
                  child: (offer.personalImage?.isNotEmpty ?? false) ? null : Icon(Icons.person, color: ColorsManager.primaryColor, size: 24.w),
                ),
                SizedBox(width: 10.w),
                // الاسم و شارة التوثيق
                Expanded(
                  child: Row(
                    children: [
                      Text(offer.fullName, style: TextStyles.font16Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(width: 6.w),
                      // شارة التوثيق
                      if (offer.isVerified)
                        Icon(Icons.verified_user_rounded, color: ColorsManager.primary400, size: 16.w),
                    ],
                  ),
                ),
                // حالة العرض (Chip)
                _StatusChip(label: _statusLabel(offer.status), color: _offerStatusColor(offer.status)),
              ],
            ),
            SizedBox(height: 12.h),

            // 2. السعر + نوع الخدمة + تاريخ ووقت العرض
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // السعر
                Expanded(
                  flex: 2,
                  child: Text(
                    '${offer.price} رس',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                ),
                // قيد التنفيذ (Request Status)
                Expanded(
                  flex: 2,
                  child: _StatusChip(
                    label: _reqLabel(offer.requestStatus),
                    color: _requestStatusColor(offer.requestStatus),
                    isOutline: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // 3. النوع و التاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge نوع المركبة
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ColorsManager.lightYellow,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(_typeLabel(offer.serviceType), style: TextStyles.font12secondary900400Weight),
                ),

                // التاريخ والوقت
                if (offer.createdAt != null)
                  Row(
                    children: [
                      Text(
                        dfTime.format(offer.createdAt!),
                        style: TextStyles.font12DarkGray400Weight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        dfDate.format(offer.createdAt!),
                        style: TextStyles.font12DarkGray400Weight,
                      ),
                    ],
                  )
              ],
            ),

            // 4. حالة القبول النهائية (إن وجدت)
            if (offer.status == 'accepted')
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: ColorsManager.success500, size: 18),
                    SizedBox(width: 6.w),
                    Text('تم القبول', style: TextStyles.font14Black500Weight),
                  ],
                ),
              )
            else if (canAccept)
              SizedBox(height: 10.h),

            // 5. زر القبول (يظهر فقط إذا كان العرض لم يُقبل بعد)
            if (canAccept)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 40.h,
                    child: ElevatedButton.icon(
                      onPressed: isAccepting ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.success500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      icon: isAccepting
                          ? SizedBox(width: 16, height: 16, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text('قبول العرض', style: TextStyles.font14White500Weight),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isOutline;
  const _StatusChip({required this.label, required this.color, this.isOutline = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: isOutline ? Border.all(color: color, width: 1) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isOutline ? color : color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}