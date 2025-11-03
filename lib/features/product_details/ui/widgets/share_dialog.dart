import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ShareDialog extends StatelessWidget {
  final String shareLink; // 👈 نستقبل رابط الإعلان هنا

  const ShareDialog({super.key, required this.shareLink});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorsManager.white,
      surfaceTintColor: ColorsManager.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 306.h,
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding:
          const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
          child: Column(
            children: [
              Text('مشاركة الرابط بواسطة',
                  style: TextStyles.font20Black500Weight),
              verticalSpace(32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔗 نسخ الرابط
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: shareLink));
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ الرابط بنجاح'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: MySvg(image: 'link', width: 40.w, height: 40.h),
                  ),
                  horizontalSpace(24),

                  // 🔵 Facebook
                  GestureDetector(
                    onTap: () {
                      final fbUrl =
                          'https://www.facebook.com/sharer/sharer.php?u=$shareLink';
                      _openUrl(fbUrl);
                      context.pop();
                    },
                    child: MySvg(image: 'logos_facebook', width: 40.w, height: 40.h),
                  ),
                  horizontalSpace(24),

                  // 🔵 Telegram
                  GestureDetector(
                    onTap: () {
                      final tgUrl = 'https://t.me/share/url?url=$shareLink';
                      _openUrl(tgUrl);
                      context.pop();
                    },
                    child: MySvg(image: 'logos_telegram', width: 40.w, height: 40.h),
                  ),
                  horizontalSpace(24),

                  // 🟢 WhatsApp
                  GestureDetector(
                    onTap: () async {
                      final encoded = Uri.encodeComponent(shareLink);
                      final waUrl = 'whatsapp://send?text=$encoded';
                      if (await canLaunchUrl(Uri.parse(waUrl))) {
                        await launchUrl(Uri.parse(waUrl),
                            mode: LaunchMode.externalApplication);
                      } else {
                        await _openUrl('https://wa.me/?text=$encoded');
                      }
                      context.pop();
                    },
                    child:
                    MySvg(image: 'logos_whatsapp-icon', width: 40.w, height: 40.h),
                  ),
                ],
              ),
              verticalSpace(32),

              MyButton(
                label: 'سوق للإعلان',
                image: 'loudspeaker',
                minWidth: 326.w,
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ميزة التسويق قيد التطوير 📢')),
                  );
                },
                backgroundColor: ColorsManager.primary50,
                radius: 16,
                height: 40.h,
                labelStyle: TextStyles.font12Primary400400Weight,
              ),

              verticalSpace(32),
              MyButton(
                label: 'حسناً',
                minWidth: 326.w,
                onPressed: () => context.pop(),
                backgroundColor: ColorsManager.primaryColor,
                radius: 12,
                height: 52.h,
                labelStyle: TextStyles.font16White500Weight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}