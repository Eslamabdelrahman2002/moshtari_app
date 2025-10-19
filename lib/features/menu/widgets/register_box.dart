import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

class RegisterBox extends StatelessWidget {
  const RegisterBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            offset: Offset(0, 2.h),
            blurRadius: 16.r,
          ),
        ],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          PrimaryButton(
            text: 'تسجيل الدخول',
            onPressed: () {
              context.pushNamed(Routes.loginScreen);
            },
          ),
        ],
      ),
    );
  }
}
