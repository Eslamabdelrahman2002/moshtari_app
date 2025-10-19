import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/enums/otp_case.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_back_icon.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/primary_check_box.dart';
import 'package:mushtary/features/auth/login/logic/cubit/login_cubit.dart';
import 'package:mushtary/features/auth/login/logic/cubit/login_state.dart';
import 'package:mushtary/features/auth/login/ui/widgets/phone_text_field.dart';
import 'package:mushtary/features/auth/otp/ui/screens/otp_screen_args.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatefulWidget {
  const _LoginScreenBody();

  @override
  State<_LoginScreenBody> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreenBody> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  bool isRememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.white,
      body: SafeArea(
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.loginResponse.message ?? 'تم إرسال كود التحقق بنجاح')),
              );

              // ✨ FIX: This now correctly navigates to the OTP screen
              final args = OtpScreenArgs(
                  phoneNumber: phoneController.text, otpCase: OtpCase.verification);
              Navigator.pushNamed(context, Routes.otpScreen, arguments: args);

            } else if (state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  verticalSpace(8),
                  const Row(children: [PrimaryBackIcon()]),
                  verticalSpace(40),
                  Text('قم بتسجيل دخولك الآن', style: TextStyles.font24Black700Weight),
                  verticalSpace(12),
                  Text('الرجاء تسجيل الدخول لمواصلة التطبيق لدينا', style: TextStyles.font16DarkGrey400Weight),
                  verticalSpace(40),
                  PhoneTextField(
                    controller: phoneController,
                    validationError: 'رقم الجوال مطلوب',
                  ),
                  verticalSpace(12),
                  Row(
                    children: [
                      PrimaryCheckBox(
                        onPressed: () {
                          setState(() {
                            isRememberMe = !isRememberMe;
                          });
                        },
                        isEnabled: isRememberMe,
                      ),
                      horizontalSpace(4),
                      Text('تذكرني', style: TextStyles.font14DarkGray400Weight),
                    ],
                  ),
                  verticalSpace(40),
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'تسجيل الدخول',
                        isLoading: state is LoginLoading,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<LoginCubit>().login(phoneController.text);
                          }
                        },
                      );
                    },
                  ),
                  verticalSpace(32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ليس لديك حساب؟', style: TextStyles.font14DarkGray400Weight),
                      horizontalSpace(8),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.pushNamed(context, Routes.registerScreen);
                        },
                        child: Text('إنشاء حساب', style: TextStyles.font14Blue500Weight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}