import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/enums/otp_case.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/auth_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_back_icon.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/primary_check_box.dart';
import 'package:mushtary/features/auth/login/ui/widgets/phone_text_field.dart';

import 'package:mushtary/features/auth/register/logic/cubit/register_state.dart';

import '../../../../../core/dependency_injection/injection_container.dart';
import '../../../otp/ui/screens/otp_screen_args.dart';
import '../../data/models/register_model.dart';
import '../../logic/cubit/refister_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterCubit>(),
      child: const _RegisterScreenBody(),
    );
  }
}

class _RegisterScreenBody extends StatefulWidget {
  const _RegisterScreenBody();

  @override
  State<_RegisterScreenBody> createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<_RegisterScreenBody> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  bool isTermsAndConditionsAccepted = false;

  void _register() {
    if (formKey.currentState!.validate() && isTermsAndConditionsAccepted) {
      final requestBody = RegisterRequestBody(
        username: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        referralCode: referralCodeController.text,
      );
      context.read<RegisterCubit>().register(requestBody);
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
        child: BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              _showSnackBar(state.successMessage);
              final args = OtpScreenArgs(
                  phoneNumber: phoneController.text,
                  otpCase: OtpCase.verification);
              Navigator.pushNamed(context, Routes.otpScreen, arguments: args);
            } else if (state is RegisterError) {
              _showSnackBar(state.error, isError: true);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    verticalSpace(8),
                    const Row(children: [PrimaryBackIcon()]),
                    verticalSpace(40),
                    Text('إنشاء حساب الأن',
                        style: TextStyles.font24Black700Weight),
                    verticalSpace(12),
                    Text('يرجى ملء التفاصيل وإنشاء الحساب',
                        style: TextStyles.font16DarkGrey400Weight),
                    verticalSpace(40),
                    AuthTextFormField(
                      controller: nameController,
                      validationError: 'الاسم مطلوب',
                      keyboardType: TextInputType.name,
                      label: 'الاسم',
                      prefixIcon: const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: MySvg(image: 'person'),
                      ),
                    ),
                    verticalSpace(24),
                    PhoneTextField(
                      controller: phoneController,
                      validationError: 'رقم الجوال مطلوب',
                    ),
                    verticalSpace(24),
                    AuthTextFormField(
                      controller: emailController,
                      validationError: 'البريد الالكتروني مطلوب',
                      keyboardType: TextInputType.emailAddress,
                      label: 'البريد الالكتروني',
                      prefixIcon: const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: MySvg(image: 'email'),
                      ),
                    ),
                    verticalSpace(24),
                    AuthTextFormField(
                      controller: referralCodeController,
                      validationError: 'رمز الإحالة غير صحيح',
                      isValidate: false,
                      keyboardType: TextInputType.text,
                      label: 'رمز الإحالة',
                      prefixIcon: const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: MySvg(image: 'copy'),
                      ),
                    ),
                    verticalSpace(12),
                    Row(
                      children: [
                        PrimaryCheckBox(
                          onPressed: () {
                            setState(() {
                              isTermsAndConditionsAccepted =
                              !isTermsAndConditionsAccepted;
                            });
                          },
                          isEnabled: isTermsAndConditionsAccepted,
                        ),
                        horizontalSpace(4),
                        Text('أوافق على ',
                            style: TextStyles.font14DarkGray400Weight),
                        InkWell(
                          onTap: () {},
                          child: Text('الشروط والأحكام',
                              style: TextStyles.font14PrimaryColor400Weight),
                        ),
                      ],
                    ),
                    verticalSpace(40),
                    BlocBuilder<RegisterCubit, RegisterState>(
                      builder: (context, state) {
                        return PrimaryButton(
                          text: 'إنشاء حساب',
                          isLoading: state is RegisterLoading,
                          isDisabled: !isTermsAndConditionsAccepted,
                          onPressed: _register,
                        );
                      },
                    ),
                    verticalSpace(32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('لديك حساب بالفعل؟',
                            style: TextStyles.font14DarkGray400Weight),
                        horizontalSpace(8),
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            Navigator.pushNamed(context, Routes.loginScreen);
                          },
                          child: Text('تسجيل الدخول',
                              style: TextStyles.font14Blue500Weight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
