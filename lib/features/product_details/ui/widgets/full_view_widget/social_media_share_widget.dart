// lib/features/product_details/ui/widgets/full_view_widget/social_media_share_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // للوصول إلى الحافظة
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:url_launcher/url_launcher.dart'; // لاستخدام الروابط

class SocialMediaShareWidget extends StatelessWidget {
  final int adId;
  final String adTitle;

  const SocialMediaShareWidget({
    super.key,
    required this.adId,
    required this.adTitle,
  });

  // دالة مساعدة لإنشاء النص ورابط المشاركة
  void _share(BuildContext context, String platformUrl) async {
    // يمكنك استبدال الرابط برابط حقيقي لتطبيقك
    final String adLink = 'https://mushtary.app/ad/$adId';
    final String shareText = 'شاهد هذا الإعلان الرائع على مشتري: $adTitle';

    // ترميز النص والرابط ليناسب الـ URL
    final String encodedText = Uri.encodeComponent(shareText);
    final String encodedLink = Uri.encodeComponent(adLink);

    // بناء الرابط النهائي بناءً على المنصة
    String finalUrl;
    if (platformUrl.contains('{link}')) {
      finalUrl = platformUrl.replaceAll('{link}', encodedLink).replaceAll('{text}', encodedText);
    } else {
      finalUrl = platformUrl.replaceAll('{text}', '$encodedText $encodedLink');
    }

    final Uri uri = Uri.parse(finalUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      context.pop(); // أغلق الـ Dialog بعد المشاركة
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح التطبيق, قد لا يكون مثبتًا')),
      );
    }
  }

  // دالة لنسخ الرابط
  void _copyLink(BuildContext context) {
    final String adLink = 'https://mushtary.app/ad/$adId';
    Clipboard.setData(ClipboardData(text: adLink)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ الرابط إلى الحافظة')),
      );
      context.pop(); // أغلق الـ Dialog بعد النسخ
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. نسخ الرابط
        GestureDetector(
            onTap: () => _copyLink(context),
            child: MySvg(
              image: 'link',
              width: 40.w,
              height: 40.h,
            )),
        horizontalSpace(24),
        // 2. فيسبوك
        GestureDetector(
            onTap: () => _share(context, 'https://www.facebook.com/sharer/sharer.php?u={link}'),
            child: MySvg(
              image: 'logos_facebook',
              width: 40.w,
              height: 40.h,
            )),
        horizontalSpace(24),
        // 3. تليجرام
        GestureDetector(
            onTap: () => _share(context, 'https://t.me/share/url?url={link}&text={text}'),
            child: MySvg(
              image: 'logos_telegram',
              width: 40.w,
              height: 40.h,
            )),
        horizontalSpace(24),
        // 4. واتساب
        GestureDetector(
            onTap: () => _share(context, 'https://wa.me/?text={text}'),
            child: MySvg(
              image: 'logos_whatsapp-icon',
              width: 40.w,
              height: 40.h,
            )),
      ],
    );
  }
}