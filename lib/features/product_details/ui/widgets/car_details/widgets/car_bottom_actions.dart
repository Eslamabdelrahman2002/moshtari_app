// lib/features/product_details/ui/widgets/car_details/widgets/car_bottom_actions.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CarBottomActions extends StatelessWidget {
  final VoidCallback? onWhatsapp;
  final VoidCallback? onCall;
  final VoidCallback? onAddBid; // ✅ زر المساومة (الرئيسي)
  final VoidCallback? onChat;
  // ❌ تم حذف onMarketing من الـ constructor (لكن نستخدمه في الشاشات الأخرى لربط زر التسويق)

  const CarBottomActions({
    super.key,
    this.onWhatsapp,
    this.onCall,
    this.onAddBid, // ✅ استلامه
    this.onChat,
  });

  // دالة مساعدة لإنشاء أيقونة الإجراءات المربعة
  Widget _buildActionButton({
    required Widget icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(child: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          // 1. زر المساومة (Expanded)
          Expanded(
            child: Container(
              // ✅ الحاوية لإضافة الحدود
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: ColorsManager.primaryColor, // 🎨 لون الحدود
                  width: 1.5,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: onAddBid, // ✅ ربط بـ onAddBid
                style: ElevatedButton.styleFrom(
                  // إزالة الحدود الداخلية للاعتماد على حدود الـ Container
                  backgroundColor: ColorsManager.white,
                  minimumSize: Size.fromHeight(48.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                  // إزالة أي حشوة قد تؤثر على مظهر الحدود
                  padding: EdgeInsets.zero,
                ),
                icon: Icon(Icons.add, color: ColorsManager.primaryColor),
                label: Text(
                  'أضف سومتك',
                  style: TextStyles.font14White500Weight.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          horizontalSpace(16),

          // 2. زر المحادثة
          _buildActionButton(
            icon: Icon(Icons.chat_bubble_outline, color: ColorsManager.primaryColor, size: 24.sp),
            color: ColorsManager.primaryColor,
            onTap: onChat,
          ),
          horizontalSpace(12),

          // 3. زر الاتصال
          _buildActionButton(
            icon: Icon(Icons.phone_outlined, color: ColorsManager.primary300, size: 24.sp),
            color: ColorsManager.primary300,
            onTap: onCall,
          ),
          horizontalSpace(12),

          // 4. زر الواتساب
          _buildActionButton(
            icon: MySvg(image: 'logos_whatsapp', color: const Color(0xFF25D366), width: 24, height: 24),
            color: const Color(0xFF25D366),
            onTap: onWhatsapp,
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color bg;
  final VoidCallback? onTap;
  final Widget icon;
  const _ActionChip({required this.label, required this.bg, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            icon,
            SizedBox(width: 6.w),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}