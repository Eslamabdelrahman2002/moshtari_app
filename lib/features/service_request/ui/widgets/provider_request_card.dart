import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import 'package:mushtary/features/service_profile/data/model/service_request_models.dart';

class ProviderRequestCard extends StatelessWidget {
  final ServiceRequest request;

  /// هل فيه عملية (Submit) شغالة على هذا الطلب؟
  final bool isBusy;

  /// استدعاء تقديم العرض
  final Future<void> Function(num price, String? message) onSubmit;

  const ProviderRequestCard({
    super.key,
    required this.request,
    required this.isBusy,
    required this.onSubmit,
  });

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'بانتظار العروض';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'منتهي';
      case 'cancelled':
        return 'ملغي';
      default:
        return s;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return ColorsManager.secondary500;
      case 'in_progress':
        return ColorsManager.primaryColor;
      case 'completed':
        return ColorsManager.success500;
      case 'cancelled':
        return ColorsManager.errorColor;
      default:
        return ColorsManager.darkGray;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>?> _showSubmitSheet(
      BuildContext context,
      ) async {
    final priceController = TextEditingController();
    final messageController = TextEditingController();

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return GestureDetector(
          onTap: () => FocusScope.of(ctx).unfocus(),
          child: Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: bottom + 16.h,
            ),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Handle صغير في الأعلى
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: ColorsManager.grey200,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Text(
                      'تقديم عرض على الطلب #${request.id}',
                      style: TextStyles.font16Black500Weight,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'أدخل السعر المناسب مع إمكانية إضافة ملاحظة للعميل.',
                      style: TextStyles.font12DarkGray400Weight,
                    ),
                    SizedBox(height: 16.h),

                    // حقل السعر
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'السعر',
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: ColorsManager.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: ColorsManager.primaryColor,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // حقل الملاحظة
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'ملاحظة (اختياري)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: ColorsManager.primaryColor,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorsManager.darkGray,
                              side: const BorderSide(
                                color: ColorsManager.dark200,
                              ),
                              minimumSize: Size(double.infinity, 44.h),
                            ),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final txt = priceController.text.trim();
                              if (txt.isEmpty) return;
                              final num? price = num.tryParse(txt);
                              if (price == null) return;
                              Navigator.of(ctx).pop({
                                'price': price,
                                'message': messageController.text.trim().isEmpty
                                    ? null
                                    : messageController.text.trim(),
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsManager.primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 44.h),
                            ),
                            child: const Text('إرسال العرض'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final customerName = request.user?.name ?? 'عميل غير معروف';

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
          color: ColorsManager.lightGrey.withOpacity(0.4),
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط علوي جمالي
            Container(
              height: 4.h,
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
                  // السطر الأول: رقم الطلب + التاريخ
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.primary50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '#${request.id}',
                          style: TextStyles.font10Primary500Weight,
                        ),
                      ),
                      const Spacer(),
                      if (request.createdAt != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14.w,
                              color: ColorsManager.darkGray300,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDate(request.createdAt),
                              style: TextStyles.font10DarkGray400Weight,
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // الحالة Chip
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _statusLabel(request.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // الوصف
                  Text(
                    request.description,
                    style: TextStyles.font14Black500Weight,
                  ),
                  SizedBox(height: 6.h),

                  // العميل
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.w,
                        color: ColorsManager.darkGray300,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          customerName,
                          style: TextStyles.font12DarkGray400Weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(color: ColorsManager.dark100),
                  SizedBox(height: 8.h),

                  // زر واحد فقط: تقديم عرض
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () async {
                        final res = await _showSubmitSheet(context);
                        if (res == null) return;
                        final price = res['price'] as num;
                        final String? msg =
                        res['message'] as String?;
                        await onSubmit(price, msg);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: isBusy
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Icon(Icons.local_offer_outlined, size: 18),
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          isBusy ? 'جاري الإرسال...' : 'تقديم عرض',
                          style: TextStyles.font14White500Weight,
                        ),
                      ),
                    ),
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