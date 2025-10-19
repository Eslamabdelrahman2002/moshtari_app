import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import '../../data/model/received_offer_models.dart';

class ReceivedOfferCard extends StatelessWidget {
  final ReceivedOffer offer;
  final VoidCallback? onTap;

  const ReceivedOfferCard({super.key, required this.offer, this.onTap});

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted':
        return ColorsManager.success500;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'بانتظار الموافقة';
    }
  }

  Color _reqColor(String s) {
    switch (s) {
      case 'completed':
        return ColorsManager.success500;
      case 'in_progress':
        return ColorsManager.primaryColor;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
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
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // provider row
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (offer.personalImage?.isNotEmpty == true)
                      ? CachedNetworkImageProvider(offer.personalImage!)
                      : null,
                  child: (offer.personalImage?.isNotEmpty ?? false) ? null : const Icon(Icons.person, color: Colors.grey),
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(offer.fullName, style: TextStyles.font14Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ColorsManager.primary50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: ColorsManager.primary200),
                  ),
                  child: Text(_typeLabel(offer.serviceType), style: TextStyles.font12Primary300400Weight),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${offer.price} رس', style: TextStyles.font16Black500Weight),
                Text(
                  offer.createdAt != null ? df.format(offer.createdAt!) : '-',
                  style: TextStyles.font12DarkGray400Weight,
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // badges
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _Chip(label: _statusLabel(offer.status), color: _statusColor(offer.status)),
                _Chip(label: _reqLabel(offer.requestStatus), color: _reqColor(offer.requestStatus)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }
}