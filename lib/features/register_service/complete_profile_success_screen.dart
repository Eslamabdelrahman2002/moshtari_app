// lib/features/auth/register/ui/screens/complete_profile_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/load_image.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/router/app_router.dart';
import 'package:mushtary/core/router/routes.dart';

class CompleteProfileSuccessScreen extends StatelessWidget {
  const CompleteProfileSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Image (Assuming 'success_pending' is the image name for the hourglass icon)
              // Note: The icon is generic, but the image name is a common convention.
              LoadImage(image: 'success_pending', width: 100.w),
              verticalSpace(32),

              // Title
              Text(
                'تم إرسال طلب التسجيل بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyles.font20Black500Weight,
              ),
              verticalSpace(8),

              // Subtitle
              Text(
                'شكراً لتسجيلك كمقدم خدمة.',
                textAlign: TextAlign.center,
                style: TextStyles.font14DarkGray400Weight,
              ),
              verticalSpace(32),

              // Detailed Message
              Text(
                // Note: The message is taken from the image content:
                // "طلبك قيد المراجعة من قبل الإدارة، وسيتم إشعارك فور قبول الحساب. نُقدر اهتمامك، وسعداء بانضمامك إلى فريق للروقين في "مشتري"."
                'طلبك قيد المراجعة من قبل الإدارة، وسيتم إشعارك فور قبول الحساب.\nنُقدر اهتمامك، وسعداء بانضمامك إلى فريق "مشتري".',
                textAlign: TextAlign.center,
                style: TextStyles.font16DarkGrey400Weight.copyWith(
                  color: ColorsManager.dark500,
                ),
              ),
              verticalSpace(64),

              // Action Button (Navigate to home/bottom nav)
              PrimaryButton(
                text: 'العودة للصفحة الرئيسية',
                onPressed: () {
                  // Using the global key function to clear the stack and go to the main navigation screen
                  AppRouter.goToBottomNavAsRoot();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}