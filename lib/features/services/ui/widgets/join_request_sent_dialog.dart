import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class JoinRequestSentDialog extends StatelessWidget {
  final String title;
  final String description;
  final String primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? successIcon; // اسم أيقونة SVG إن أحببت
  final bool showCloseIcon;

  const JoinRequestSentDialog({
    super.key,
    this.title = 'تم إرسال الطلب بنجاح',
    this.description =
    'تم إرسال طلبك للانضمام إلى الرحلة بنجاح، وهو الآن بانتظار موافقة مقدم الخدمة. '
        'ستصلك إشعارات فور قبول الطلب أو في حال وجود أي ملاحظات.',
    this.primaryActionText = 'العودة للرئيسية',
    this.onPrimaryAction,
    this.successIcon,
    this.showCloseIcon = true,
  });

  static Future<T?> show<T>(
      BuildContext context, {
        String? title,
        String? description,
        String? primaryActionText,
        VoidCallback? onPrimaryAction,
        String? successIcon,
        bool showCloseIcon = true,
        bool barrierDismissible = true,
      }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: JoinRequestSentDialog(
          title: title ?? 'تم إرسال الطلب بنجاح',
          description: description ??
              'تم إرسال طلبك للانضمام إلى الرحلة بنجاح، وهو الآن بانتظار موافقة مقدم الخدمة. '
                  'ستصلك إشعارات فور قبول الطلب أو في حال وجود أي ملاحظات.',
          primaryActionText: primaryActionText ?? 'العودة للرئيسية',
          onPrimaryAction: onPrimaryAction,
          successIcon: successIcon,
          showCloseIcon: showCloseIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة النجاح
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                  child: successIcon != null
                      ? MySvg(image: successIcon!, width: 64.w, height: 64.h)
                      : Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 64.r),
                ),

                verticalSpace(12),

                Text(
                  title,
                  style: TextStyles.font18Black500Weight,
                  textAlign: TextAlign.center,
                ),

                verticalSpace(8),

                Text(
                  description,
                  style: TextStyles.font14Black400Weight.copyWith(
                    color: ColorsManager.darkGray300,
                  ),
                  textAlign: TextAlign.center,
                ),

                verticalSpace(24),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: ColorsManager.primaryColor, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      // اغلاق الدialog
                      Navigator.of(context, rootNavigator: true).pop();
                      // تنفيذ الإجراء الأساسي
                      onPrimaryAction?.call();
                    },
                    child: Text(
                      primaryActionText,
                      style: TextStyles.font16Black500Weight.copyWith(
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // زر الإغلاق
          if (showCloseIcon)
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                child: MySvg(
                  image: 'close_circle',
                  height: 22.w,
                  width: 22.w,
                  color: ColorsManager.darkGray300,
                ),
              ),
            ),
        ],
      ),
    );
  }
}