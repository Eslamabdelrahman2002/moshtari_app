import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/enums/otp_case.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/input_formats.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_back_icon.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/auth/reset_password/data/model/reset_password_args.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../core/dependency_injection/injection_container.dart';
import '../../cubit/otp_cubit.dart';
import '../../cubit/otp_state.dart';
import 'otp_screen_args.dart';

class OtpScreen extends StatelessWidget {
  final OtpScreenArgs otpScreenArgs;
  const OtpScreen({super.key, required this.otpScreenArgs});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // ✨ DEBUG PRINT 1 ✨
        print("--- Trying to create OtpCubit via BlocProvider ---");
        try {
          final cubit = getIt<OtpCubit>();
          print("--- OtpCubit created successfully! ---");
          return cubit;
        } catch (e) {
          print("--- ERROR creating OtpCubit: ${e.toString()} ---");
          // Return a dummy/fallback instance if creation fails to avoid crashing the build method
          // This part is for debugging only.
          throw Exception("Failed to create OtpCubit: $e");
        }
      },
      child: _OtpScreenBody(otpScreenArgs: otpScreenArgs),
    );
  }
}

class _OtpScreenBody extends StatefulWidget {
  final OtpScreenArgs otpScreenArgs;
  const _OtpScreenBody({required this.otpScreenArgs});

  @override
  State<_OtpScreenBody> createState() => _OtpScreenBodyState();
}

class _OtpScreenBodyState extends State<_OtpScreenBody> {
  final TextEditingController otpController = TextEditingController();

  void _verifyOtp() {
    print('Button pressed! OTP text is: "${otpController.text}", Length is: ${otpController.text.length}');
    if (otpController.text.length == 4) {
      try {
        // ✨ DEBUG PRINT 2 ✨
        print("--- Trying to call Cubit method ---");
        context.read<OtpCubit>().verifyOtp(
          phoneNumber: widget.otpScreenArgs.phoneNumber,
          otp: otpController.text,
          otpCase: widget.otpScreenArgs.otpCase,
        );
        // ✨ DEBUG PRINT 3 ✨
        print("--- Cubit method call finished (no immediate error) ---");
      } catch (e) {
        // ✨ DEBUG PRINT 4 ✨
        print("--- ERROR calling/finding Cubit: ${e.toString()} ---");
      }
    } else {
      _showSnackBar('Please enter a valid OTP', isError: true);
    }
  }

  void _resendOtp() {
    context.read<OtpCubit>().resendOtp(
      widget.otpScreenArgs.phoneNumber,
    );
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
        child: BlocListener<OtpCubit, OtpState>(
          listener: (context, state) {
            if (state is OtpVerificationSuccess) {
              _showSnackBar(state.message);

              if (widget.otpScreenArgs.otpCase == OtpCase.resetPassword) {
                final args = ResetPasswordArgs(
                  phoneNumber: widget.otpScreenArgs.phoneNumber,
                  otp: state.otp,
                );
                Navigator.pushNamed(context, Routes.resetPasswordScreen,
                    arguments: args);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.bottomNavigationBar, (route) => false);
              }
            } else if (state is OtpVerificationError) {
              _showSnackBar(state.error, isError: true);
            } else if (state is ResendOtpSuccess) {
              _showSnackBar(state.message);
            } else if (state is ResendOtpError) {
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('التحقق من OTP',
                          style: TextStyles.font24Black700Weight),
                      verticalSpace(12),
                      Text(
                        'يرجى التحقق من رقمك ${widget.otpScreenArgs.phoneNumber} لرؤية رمز التحقق',
                        textAlign: TextAlign.center,
                        style: TextStyles.font16DarkGrey400Weight,
                      ),
                    ],
                  ),
                ),
                verticalSpace(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: PinCodeTextField(
                    controller: otpController,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    appContext: context,
                    length: 4,
                    autoDisposeControllers: false,
                    animationType: AnimationType.fade,
                    inputFormatters: [AppInputFormats.numbersFormat],
                    keyboardType: TextInputType.number,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorsManager.black,
                    ),
                    pinTheme: PinTheme(
                      borderWidth: 1,
                      activeColor: ColorsManager.lightGrey,
                      inactiveColor: ColorsManager.lightGrey,
                      selectedColor: ColorsManager.primaryColor,
                      errorBorderColor: Colors.red,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 48,
                      fieldWidth: 48,
                      activeFillColor: Colors.white,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                  ),
                ),
                verticalSpace(40),
                BlocBuilder<OtpCubit, OtpState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'تأكيد',
                      isLoading: state is OtpVerificationLoading,
                      onPressed: _verifyOtp,
                    );
                  },
                ),
                verticalSpace(16),
                Row(
                  children: [
                    Text('إعادة إرسال الرمز بعد',
                        style: TextStyles.font14DarkGray400Weight),
                    const Spacer(),
                    BlocBuilder<OtpCubit, OtpState>(
                      builder: (context, state) {
                        if (state is ResendOtpLoading) {
                          return const CircularProgressIndicator();
                        }
                        return InkWell(
                          onTap: _resendOtp,
                          child: Text('إعادة إرسال',
                              style: TextStyles.font14PrimaryColor400Weight),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}