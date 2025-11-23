import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import '../../../model/data/my_requests_models.dart';

class OfferListTile extends StatelessWidget {
  final ServiceRequestItem request;
  final RequestOfferItem offer;
  final int? actingOfferId;
  final void Function(int offerId)? onAccept;
  final void Function(int offerId)? onReject;

  const OfferListTile({
    super.key,
    required this.request,
    required this.offer,
    this.actingOfferId,
    this.onAccept,
    this.onReject,
  });

  // ✅ نسمح بالأزرار لأي عرض ليس accepted أو rejected
  bool get _canAct =>
      offer.status != 'accepted' && offer.status != 'rejected';

  bool get _isBusy => actingOfferId == offer.offerId;

  String _reqLabel(String s) {
    switch (s) {
      case 'completed':
        return 'منتهي';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'بانتظار العروض';
    }
  }

  Color _requestStatusColor(String s) {
    switch (s) {
      case 'completed':
        return ColorsManager.success500;
      case 'in_progress':
        return ColorsManager.primaryColor;
      case 'cancelled':
        return ColorsManager.errorColor;
      default:
        return ColorsManager.darkGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _requestStatusColor(request.requestStatus);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
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
        border: Border.all(
          color: ColorsManager.lightGrey.withOpacity(0.6),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          // يسار: السعر + الحالة / الأزرار
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // السعر في Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: ColorsManager.success100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '#${offer.price}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorsManager.success500,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              if (_canAct)
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _isBusy
                          ? null
                          : () => onReject?.call(offer.offerId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorsManager.errorColor,
                        side: const BorderSide(
                            color: ColorsManager.errorColor),
                        minimumSize: Size(64.w, 32.h),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                      ),
                      child: _isBusy
                          ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('رفض'),
                    ),
                    SizedBox(width: 6.w),
                    ElevatedButton(
                      onPressed: _isBusy
                          ? null
                          : () => onAccept?.call(offer.offerId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.success500,
                        foregroundColor: Colors.white,
                        minimumSize: Size(64.w, 32.h),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                      ),
                      child: _isBusy
                          ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Text('قبول'),
                    ),
                  ],
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _reqLabel(request.requestStatus),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 12.w),

          // يمين: معلومات المزوّد + المدينة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // اسم المزوّد
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        offer.providerName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.verified_user,
                      size: 16.w,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),

                // الهاتف
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        offer.providerPhone,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.phone, size: 14.w, color: Colors.grey[500]),
                  ],
                ),
                SizedBox(height: 4.h),

                // المدينة
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        request.cityName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.w,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}