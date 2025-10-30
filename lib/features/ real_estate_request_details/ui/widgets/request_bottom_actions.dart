import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../../core/utils/helpers/spacing.dart';

class RequestBottomActions extends StatelessWidget {
  final VoidCallback? onWhatsapp;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  const RequestBottomActions({
    super.key,
    this.onWhatsapp,
    this.onCall,
    this.onChat,
  });

  // دالة مساعدة لإنشاء أيقونة الإجراءات المربعة/المستديرة بالتصميم الجديد
  Widget _buildActionButton({
    required Widget icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback? onTap,
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: icon,
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء زر المحادثة (الذي يحتوي على أيقونة مختلفة)
  Widget _buildChatButton() {
    return _buildActionButton(
      icon: Icon(Icons.chat_bubble_outline, color: ColorsManager.primaryColor, size: 24.sp),
      iconColor: ColorsManager.primaryColor,
      bgColor: ColorsManager.primaryColor.withOpacity(0.08), // خلفية بنفسجية فاتحة
      onTap: onChat,
    );
  }

  // دالة مساعدة لإنشاء زر الاتصال
  Widget _buildCallButton() {
    return _buildActionButton(
      icon: Icon(Icons.phone_outlined, color: ColorsManager.primary300, size: 24.sp),
      iconColor: ColorsManager.primary300,
      bgColor: ColorsManager.primary300.withOpacity(0.08), // خلفية زرقاء فاتحة
      onTap: onCall,
    );
  }

  // دالة مساعدة لإنشاء زر الواتساب
  Widget _buildWhatsappButton() {
    const whatsappColor = Color(0xFF25D366);
    return _buildActionButton(
      icon: MySvg(image: 'logos_whatsapp', color: whatsappColor, width: 24, height: 24),
      iconColor: whatsappColor,
      bgColor: whatsappColor.withOpacity(0.08), // خلفية خضراء فاتحة
      onTap: onWhatsapp,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. زر الواتساب
          _buildWhatsappButton(),
          horizontalSpace(12),

          // 2. زر الاتصال
          _buildCallButton(),
          horizontalSpace(12),

          // 3. زر المحادثة
          _buildChatButton(),
        ],
      ),
    );
  }
}