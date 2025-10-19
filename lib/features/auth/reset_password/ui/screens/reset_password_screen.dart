import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_back_icon.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/auth/login/ui/widgets/password_text_field.dart';


import '../../../../../core/dependency_injection/injection_container.dart';
import '../logic/cubit/reset_password_cubit.dart';
import '../logic/cubit/reset_password_state.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String phoneNumber;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ResetPasswordCubit>(),
      child: _ResetPasswordScreenBody(
        phoneNumber: phoneNumber,
        otp: otp,
      ),
    );
  }
}

class _ResetPasswordScreenBody extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const _ResetPasswordScreenBody({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<_ResetPasswordScreenBody> createState() =>
      __ResetPasswordScreenBodyState();
}

class __ResetPasswordScreenBodyState extends State<_ResetPasswordScreenBody> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void _resetPassword() {
    if (formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        _showSnackBar('كلمتا المرور غير متطابقتين', isError: true);
        return;
      }
      context.read<ResetPasswordCubit>().resetPassword(
        phoneNumber: widget.phoneNumber,
        otp: widget.otp,
        newPassword: passwordController.text,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.white,
      body: SafeArea(
        child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              _showSnackBar(state.message);
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                    (route) => false,
              );
            } else if (state is ResetPasswordError) {
              _showSnackBar(state.error, isError: true);
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
                  Text('إعادة تعيين كلمة المرور',
                      style: TextStyles.font24Black700Weight),
                  verticalSpace(33),
                  PasswordTextField(
                    controller: passwordController,
                    label: 'كلمة المرور الجديدة',
                  ),
                  verticalSpace(24),
                  PasswordTextField(
                    controller: confirmPasswordController,
                    label: 'تأكيد كلمة المرور الجديدة',
                  ),
                  verticalSpace(87),
                  BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'إعادة تعيين',
                        isLoading: state is ResetPasswordLoading,
                        onPressed: _resetPassword,
                      );
                    },
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
