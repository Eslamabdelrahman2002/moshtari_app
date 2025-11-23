// lib/features/services/ui/widgets/service_contact_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// يجب توفر هذه الاستيرادات في مشروعك
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
// import 'package:mushtary/core/utils/helpers/launcher.dart'; // لفتح الاتصال/الواتساب
// import 'package:mushtary/core/router/routes.dart'; // للانتقال إلى صفحة المحادثة

// ✅ FIX: نموذج بيانات لغرض تمرير بيانات مزود الخدمة لرحلات "دينات"
// تم تعديل الحقول لتناسب ما يتم تمريره من DinatGridItem
class ContactInfo {
  final int ownerId;
  final String ownerName;
  final String? ownerImage;
  final String? ownerPhone;
  final String fromCityName;
  final String toCityName;
  final int adId;

  ContactInfo({
    required this.ownerId,
    required this.ownerName,
    this.ownerImage,
    this.ownerPhone,
    required this.fromCityName,
    required this.toCityName,
    required this.adId,
  });
}

/// ✅ FIX: دالة مساعدة لفتح الشاشة المنبثقة
void showServiceContactSheet(BuildContext context, {required ContactInfo info, Function(int receiverId, String receiverName, int adId)? onStartChat}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ServiceContactSheet(info: info, onStartChat: onStartChat),
  );
}

class ServiceContactSheet extends StatelessWidget {
  final ContactInfo info;
  final Function(int receiverId, String receiverName, int adId)? onStartChat;

  const ServiceContactSheet({super.key, required this.info, this.onStartChat});

  // الدوال الوظيفية
  void onChat(BuildContext context) {
    Navigator.pop(context);
    if (onStartChat != null) {
      onStartChat!(info.ownerId, info.ownerName, info.adId);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري بدء المحادثة مع: ${info.ownerName} بخصوص الإعلان رقم ${info.adId}')),
    );
  }

  void onCall(BuildContext context) {
    Navigator.pop(context);
    if (info.ownerPhone != null && info.ownerPhone!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الاتصال بالرقم: ${info.ownerPhone}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يتوفر رقم هاتف لهذا المزود.')),
      );
    }
  }

  void onWhatsapp(BuildContext context) {
    Navigator.pop(context);
    if (info.ownerPhone != null && info.ownerPhone!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('بدء واتساب مع: ${info.ownerPhone}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يتوفر رقم واتساب لهذا المزود.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. العنوان
            Center(
              child: Text(
                'طلب خدمة النقل',
                style: TextStyles.font16Dark400Weight,
              ),
            ),
            verticalSpace(24),

            // 2. معلومات الرحلة
            Row(
              children: [
                // صورة مزود الخدمة
                ClipOval(
                  child: Image.network(
                    info.ownerImage ?? 'https://via.placeholder.com/50',
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: const BoxDecoration(color: ColorsManager.grey200, shape: BoxShape.circle),
                      child: Icon(Icons.person, size: 30.sp, color: ColorsManager.darkGray),
                    ),
                  ),
                ),
                horizontalSpace(12),
                // تفاصيل المزود والرحلة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.ownerName,
                        style: TextStyles.font16Dark400Weight,
                      ),
                      verticalSpace(4),
                      Text(
                        '${info.fromCityName} إلى ${info.toCityName}',
                        style: TextStyles.font14Dark500400Weight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpace(32),

            // 3. أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // زر المحادثة (Chat)
                _buildActionButton(
                  context,
                  iconWidget: Icon(Icons.chat_bubble_outline, color: ColorsManager.primaryColor, size: 24.sp),
                  label: 'محادثة',
                  onTap: () => onChat(context),
                ),

                // زر الاتصال (Call)
                _buildActionButton(
                  context,
                  iconWidget: Icon(Icons.phone_outlined, color: ColorsManager.primary300, size: 24.sp),
                  label: 'اتصال',
                  onTap: () => onCall(context),
                ),

                // زر الواتساب (WhatsApp)
                _buildActionButton(
                  context,
                  iconWidget: MySvg(image: 'mingcute_whatsapp-line', color: const Color(0xFF25D366), width: 24, height: 24),
                  label: 'واتساب',
                  onTap: () => onWhatsapp(context),
                ),
              ],
            ),
            verticalSpace(16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required Widget iconWidget,
        required String label,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: ColorsManager.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: iconWidget),
          ),
          verticalSpace(8),
          Text(
            label,
            style: TextStyles.font12Dark500400Weight.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}