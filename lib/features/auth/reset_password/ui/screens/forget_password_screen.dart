import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/enums/otp_case.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_back_icon.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import 'package:mushtary/features/auth/login/ui/widgets/phone_text_field.dart';

import '../../../../../core/dependency_injection/injection_container.dart';
import '../../../otp/ui/screens/otp_screen_args.dart';
import '../logic/cubit/forget_password_cubit.dart';
import '../logic/cubit/forget_password_state.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ForgetPasswordCubit>(),
      child: const _ForgetPasswordScreenBody(),
    );
  }
}

class _ForgetPasswordScreenBody extends StatefulWidget {
  const _ForgetPasswordScreenBody();

  @override
  State<_ForgetPasswordScreenBody> createState() =>
      _ForgetPasswordScreenBodyState();
}

class _ForgetPasswordScreenBodyState extends State<_ForgetPasswordScreenBody> {
  final phoneController = TextEditingController();

  void _sendOtp() {
    if (phoneController.text.isNotEmpty) {
      context.read<ForgetPasswordCubit>().forgetPassword(phoneController.text);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.white,
      body: SafeArea(
        child: BlocListener<ForgetPasswordCubit, ForgetPasswordState>(
          listener: (context, state) {
            if (state is ForgetPasswordSuccess) {
              _showSnackBar(state.message);
              final args = OtpScreenArgs(
                  phoneNumber: phoneController.text,
                  otpCase: OtpCase.resetPassword);
              Navigator.pushNamed(context, Routes.otpScreen, arguments: args);
            } else if (state is ForgetPasswordError) {
              _showSnackBar(state.error, isError: true);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpace(8),
                const Row(children: [PrimaryBackIcon()]),
                verticalSpace(40),
                Text('نسيت كلمة المرور',
                    style: TextStyles.font24Black700Weight),
                verticalSpace(12),
                Text('الرجاء ادخال الجوال المسجل للتحديث',
                    style: TextStyles.font16DarkGrey400Weight),
                verticalSpace(40),
                PhoneTextField(controller: phoneController),
                verticalSpace(54),
                BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'ارسال رقم التحقق',
                      isLoading: state is ForgetPasswordLoading,
                      onPressed: _sendOtp,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
