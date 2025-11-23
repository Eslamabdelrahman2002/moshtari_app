import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import '../../../model/data/my_requests_models.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequestItem request;
  final int? actingOfferId;
  final void Function(int offerId)? onAccept;
  final void Function(int offerId)? onReject;

  const RequestCard({
    super.key,
    required this.request,
    this.actingOfferId,
    this.onAccept,
    this.onReject,
  });

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

  String _typeLabel(String t) {
    switch (t) {
      case 'dyna':
        return 'دينّا';
      case 'flatbed':
        return 'سطحة';
      case 'tanker':
        return 'صهريج ماء';
      default:
        return t;
    }
  }

  Color _offerStatusColor(String s) {
    switch (s) {
      case 'accepted':
        return ColorsManager.success500;
      case 'rejected':
        return ColorsManager.errorColor;
      default:
        return ColorsManager.secondary500;
    }
  }

  String _offerStatusLabel(String s) {
    switch (s) {
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'مقترح';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _requestStatusColor(request.requestStatus);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: ColorsManager.lightGrey.withOpacity(0.5),
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.blueGradient1,
                    ColorsManager.blueGradient2,
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.secondary50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 14.w,
                              color: ColorsManager.secondary500,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _typeLabel(request.serviceType),
                              style: TextStyles.font12secondary900400Weight,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      Icon(
                        Icons.location_on_outlined,
                        size: 16.w,
                        color: ColorsManager.darkGray300,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          request.cityName,
                          style: TextStyles.font14Black500Weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
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
                  SizedBox(height: 8.h),

                  Text(
                    request.description,
                    style: TextStyles.font12DarkGray400Weight,
                  ),
                  SizedBox(height: 10.h),

                  Divider(color: ColorsManager.dark100),
                  SizedBox(height: 6.h),

                  if (request.offers.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16.w,
                            color: ColorsManager.darkGray300,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'لا توجد عروض لهذا الطلب',
                            style: TextStyles.font12DarkGray400Weight,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 16.w,
                              color: ColorsManager.primaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'العروض (${request.offers.length})',
                              style: TextStyles.font14Black500Weight,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        for (final offer in request.offers) ...[
                          _OfferRow(
                            offer: offer,
                            // 👇 إخفاء الأزرار إذا كان العرض مقبول / مرفوض
                            hideButtons: offer.status == 'accepted' || offer.status == 'rejected',

                            disabled: actingOfferId == offer.offerId,
                            onAccept: () => onAccept?.call(offer.offerId),
                            onReject: () => onReject?.call(offer.offerId),
                            statusColor: _offerStatusColor(offer.status),
                            statusLabel: _offerStatusLabel(offer.status),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final RequestOfferItem offer;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool disabled;
  final bool hideButtons;
  final Color statusColor;
  final String statusLabel;

  const _OfferRow({
    required this.offer,
    required this.onAccept,
    required this.onReject,
    required this.disabled,
    required this.hideButtons,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: ColorsManager.dark50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ColorsManager.lightGrey.withOpacity(0.8),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
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
              const Spacer(),
              Flexible(
                child: Row(
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
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified_user,
                      size: 16.w,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                offer.providerPhone,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(width: 4),
              Icon(Icons.phone, size: 14.w, color: Colors.grey[500]),
            ],
          ),
          SizedBox(height: 8.h),

          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              const Spacer(),

              // 👇 لو العرض مقبول/مرفوض → اختفاء تام للأزرار
              if (!hideButtons) ...[
                OutlinedButton(
                  onPressed: disabled ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.errorColor,
                    side: const BorderSide(color: ColorsManager.errorColor),
                    minimumSize: Size(72.w, 34.h),
                  ),
                  child: disabled
                      ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('رفض'),
                ),
                const SizedBox(width: 6),

                ElevatedButton(
                  onPressed: disabled ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.success500,
                    foregroundColor: Colors.white,
                    minimumSize: Size(72.w, 34.h),
                  ),
                  child: disabled
                      ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text('قبول'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
