import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

// class AuctionStepperHeader extends StatelessWidget {
//   final int currentStep; // 0..2
//   const AuctionStepperHeader({super.key, required this.currentStep});
//
//   @override
//   Widget build(BuildContext context) {
//     final steps = ['حدد التصنيف', 'تفاصيل متقدمة', 'معلومات العرض'];
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Row(
//         children: List.generate(3, (i) {
//           final active = i == currentStep;
//           return Expanded(
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 10,
//                   backgroundColor: active ? ColorsManager.secondary500 : ColorsManager.dark200,
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: Text(
//                     steps[i],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: active
//                         ? TextStyles.font12Blue400Weight.copyWith(color: ColorsManager.secondary500)
//                         : TextStyles.font12DarkGray400Weight,
//                   ),
//                 ),
//                 if (i < 2)
//                   Container(
//                     margin: EdgeInsets.symmetric(horizontal: 8.w),
//                     height: 2,
//                     width: 24.w,
//                     color: i < currentStep ? ColorsManager.secondary500 : ColorsManager.dark200,
//                   ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

class DashedActionBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const DashedActionBox({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: ColorsManager.dark200,
      strokeWidth: 1.2,
      borderType: BorderType.RRect,
      radius: Radius.circular(12.r),
      dashPattern: const [6, 4],
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          height: 56.h,
          alignment: Alignment.center,
          child: Text(title, style: TextStyles.font14Blue500Weight),
        ),
      ),
    );
  }
}

Future<void> showAuctionSuccessDialog(
    BuildContext context, {
      required String title,
      required String message,

      VoidCallback? onBackHome,
    }) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
              SizedBox(height: 8.h),
              Icon(Icons.emoji_events_rounded, size: 48.sp, color: ColorsManager.secondary500),
              SizedBox(height: 12.h),
              Text(title, style: TextStyles.font16Black500Weight),
              SizedBox(height: 8.h),
              Text(message, textAlign: TextAlign.center, style: TextStyles.font14DarkGray400Weight),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onBackHome ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorsManager.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text('العودة للرئيسية'),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showAuctionErrorDialog(
    BuildContext context, {
      String title = 'تعذّر إنشاء المزاد',
      required String message,
      VoidCallback? onClose,
    }) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
              SizedBox(height: 8.h),
              Icon(Icons.error_outline_rounded, size: 48.sp, color: ColorsManager.errorColor),
              SizedBox(height: 12.h),
              Text(title, style: TextStyles.font16Black500Weight),
              SizedBox(height: 8.h),
              Text(message, textAlign: TextAlign.center, style: TextStyles.font14DarkGray400Weight),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClose ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: const Text('حسنًا'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
} 