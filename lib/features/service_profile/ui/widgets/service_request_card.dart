// lib/features/product_details/ui/widgets/service_request_card.dart (Updated)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart'; // 💡 NEW: Added spacing helper
import '../../data/model/service_request_models.dart';


class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest req;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  // أبقيت onComplete اختيارياً لو عندك استدعاءات قديمة، لكنه غير مستخدم الآن
  final VoidCallback? onComplete;

  final bool isLoading;

  const ServiceRequestCard({
    super.key,
    required this.req,
    this.onAccept,
    this.onReject,
    this.onComplete,
    this.isLoading = false,
  });

  Color _statusBgColor(String s) {
    switch (s) {
      case 'completed':
        return ColorsManager.success100;
      case 'cancelled':
      // خلفية فاتحة للإلغاء
        return ColorsManager.redButton.withOpacity(0.1);
      case 'pending':
        return ColorsManager.lightYellow;
      default:
        return ColorsManager.dark50;
    }
  }

  Color _statusTextColor(String s) {
    switch (s) {
      case 'completed':
        return ColorsManager.success500;
      case 'cancelled':
        return ColorsManager.redButton;
      case 'pending':
        return ColorsManager.secondary500;
      default:
        return ColorsManager.darkGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = req.status;
    final isPending = status == 'pending';
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) العميل + شارة الحالة
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: ColorsManager.lightGrey,
                backgroundImage: (req.user?.personalImage?.isNotEmpty == true)
                    ? CachedNetworkImageProvider(req.user!.personalImage!)
                    : null,
                child: (req.user?.personalImage?.isNotEmpty ?? false)
                    ? null
                    : const Icon(Icons.person, color: Colors.grey),
              ),
              horizontalSpace(10),
              Expanded(
                child: Text(
                  req.user?.name ?? 'عميل',
                  style: TextStyles.font16Black500Weight,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _statusBgColor(status),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  isCompleted
                      ? 'تم التنفيذ'
                      : isCancelled
                      ? 'تم الإلغاء'
                      : 'بانتظار الموافقة',
                  style: TextStyle(
                    color: _statusTextColor(status),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 2) الوصف
          Text('تفاصيل الطلب:', style: TextStyles.font14DarkGray400Weight),
          SizedBox(height: 4.h),
          Text(
            req.description,
            style: TextStyles.font14Black500Weight,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),

          // 3) الأفعال: فقط في حالة pending
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(0, 40.h),
                    ),
                    child: Text('تم التنفيذ', style: TextStyles.font14White500Weight),
                  ),
                ),
                horizontalSpace(12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: ColorsManager.redButton,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(0, 40.h),
                    ),
                    child: Text(
                      'الغاء',
                      style: TextStyle(
                        color: ColorsManager.redButton,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}