import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import '../../data/model/received_offer_models.dart';

class ReceivedOfferCard extends StatelessWidget {
  final ReceivedOffer offer;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isBusy;
  final VoidCallback? onTap;

  const ReceivedOfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.isBusy = false,
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
      default:
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
    final canAct = offer.status == 'pending';

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
            // Top Row
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: ColorsManager.primary50,
                  backgroundImage: (offer.personalImage?.isNotEmpty == true)
                      ? CachedNetworkImageProvider(offer.personalImage!)
                      : null,
                  child: (offer.personalImage?.isNotEmpty ?? false)
                      ? null
                      : Icon(Icons.person, color: ColorsManager.primaryColor, size: 24.w),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          offer.fullName,
                          style: TextStyles.font16Black500Weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (offer.isVerified)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(Icons.verified_user_rounded, color: ColorsManager.primary400, size: 16.w),
                        ),
                    ],
                  ),
                ),
                _StatusChip(label: _statusLabel(offer.status), color: _offerStatusColor(offer.status)),
              ],
            ),
            SizedBox(height: 12.h),

            // Price + Request Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

            // Type + date/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ColorsManager.lightYellow,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(_typeLabel(offer.serviceType), style: TextStyles.font12secondary900400Weight),
                ),
                if (offer.createdAt != null)
                  Row(
                    children: [
                      Text(dfTime.format(offer.createdAt!), style: TextStyles.font12DarkGray400Weight),
                      SizedBox(width: 4.w),
                      Text(dfDate.format(offer.createdAt!), style: TextStyles.font12DarkGray400Weight),
                    ],
                  )
              ],
            ),

            // Accepted banner
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
            else if (canAct)
              SizedBox(height: 10.h),

            // Actions
            if (canAct)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Reject
                  SizedBox(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: isBusy ? null : onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorsManager.errorColor,
                        side: const BorderSide(color: ColorsManager.errorColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      icon: isBusy
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                          : const Icon(Icons.close_rounded, size: 18),
                      label: Text('رفض', style: TextStyles.font14Black500Weight.copyWith(color: ColorsManager.errorColor)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Accept
                  SizedBox(
                    height: 40.h,
                    child: ElevatedButton.icon(
                      onPressed: isBusy ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.success500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      icon: isBusy
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(Colors.white), strokeWidth: 2))
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text('قبول', style: TextStyles.font14White500Weight),
                    ),
                  ),
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
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}