import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import '../../data/model/service_request_models.dart';



class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest req;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  const ServiceRequestCard({
    super.key,
    required this.req,
    this.onAccept,
    this.onReject,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final status = req.status;
    final isPending = status == 'pending';
    final inProgress = status == 'in_progress';
    final done = status == 'completed';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: (req.user?.personalImage?.isNotEmpty == true)
                    ? CachedNetworkImageProvider(req.user!.personalImage!)
                    : null,
                child: (req.user?.personalImage?.isNotEmpty ?? false) ? null : const Icon(Icons.person, color: Colors.grey),
              ),
              SizedBox(width: 8.w),
              Expanded(child: Text(req.user?.name ?? 'عميل', style: TextStyles.font14Black500Weight)),
              if (done)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: ColorsManager.success100, borderRadius: BorderRadius.circular(16.r)),
                  child: Text('تم الانتهاء', style: TextStyle(color: ColorsManager.success500, fontWeight: FontWeight.w700)),
                )
              else if (inProgress)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: ColorsManager.primary50, borderRadius: BorderRadius.circular(16.r)),
                  child: Text('قيد التنفيذ', style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w700)),
                )
              else if (isPending)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: ColorsManager.whiteGray.withOpacity(.5), borderRadius: BorderRadius.circular(16.r)),
                    child: const Text('بانتظار الموافقة', style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w700)),
                  ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(req.description, style: TextStyles.font12DarkGray400Weight, maxLines: 3, overflow: TextOverflow.ellipsis),
          SizedBox(height: 12.h),

          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAccept,
                    style: OutlinedButton.styleFrom(
                      backgroundColor:ColorsManager.primaryColor ,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('موافقة', style: TextStyle(color: ColorsManager.white, fontWeight: FontWeight.w700)),
                  ),
                ),

                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('رفض', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            )
          else if (inProgress)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onComplete,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorsManager.primaryColor),
                  backgroundColor: ColorsManager.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('تم الانتهاء', style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}