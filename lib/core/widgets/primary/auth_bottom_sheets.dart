import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/enums/otp_case.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/primary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/primary_check_box.dart';
import 'package:mushtary/features/auth/login/logic/cubit/login_cubit.dart';
import 'package:mushtary/features/auth/login/logic/cubit/login_state.dart';
import 'package:mushtary/features/auth/login/ui/widgets/phone_text_field.dart';
import 'package:mushtary/features/auth/register/data/models/register_model.dart';
import 'package:mushtary/features/auth/register/logic/cubit/refister_cubit.dart';
import 'package:mushtary/features/auth/register/logic/cubit/register_state.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../features/auth/otp/cubit/otp_cubit.dart';
import '../../../features/auth/otp/cubit/otp_state.dart';
import '../../utils/helpers/input_formats.dart';

/// نتيجة نهائية للـ Bottom Sheet: إذا كانت True، سيتم التوجيه إلى الشاشة الرئيسية
Future<bool?> showAuthFlow(BuildContext context) async {
  print('🟢 showAuthFlow: Starting...'); // 🟢 Log
  // نفتح شاشة تسجيل الدخول. إذا نجحت (رجعت True)، سيتم التوجيه.
  final isFinished = await showLoginSheet(context);
  print('🟢 showAuthFlow: showLoginSheet returned: $isFinished'); // 🟢 Log

  // 🟢 تصحيح: لو null، رجع false (بدل null) عشان ما يحصلش crash في AuthCoordinator
  return isFinished ?? false;
}

/// ---------- Common Wrapper ----------
Future<T?> _showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  print('🟢 _showAppBottomSheet: Showing sheet...'); // 🟢 Log
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (ctx) {
      final bottom = MediaQuery.of(ctx).viewInsets.bottom;
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            // استخدام الـ BlocProvider هنا لضمان توفيره داخل الـ Sheets
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<LoginCubit>()),
                BlocProvider(create: (_) => getIt<RegisterCubit>()),
                BlocProvider(create: (_) => getIt<OtpCubit>()),
              ],
              child: SafeArea(top: false, child: child),
            ),
          ),
        ),
      );
    },
  ).then((result) {
    print('🟢 _showAppBottomSheet: Sheet closed with result: $result'); // 🟢 Log
    return result;
  });
}

// =========================================================================
// ********** شاشة تسجيل الدخول (LOGIN Sheet) **********
// =========================================================================

Future<bool?> showLoginSheet(BuildContext context) {
  print('🟢 showLoginSheet: Opening...'); // 🟢 Log
  return _showAppBottomSheet<bool>(
    context: context,
    child: const _LoginSheet(),
  ).then((result) {
    print('🟢 showLoginSheet: Closed with result: $result'); // 🟢 Log
    return result;
  });
}

class _LoginSheet extends StatefulWidget {
  const _LoginSheet();
  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool isRememberMe = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        print('🟢 _LoginSheet: State changed: $state'); // 🟢 Log
        if (state is LoginSuccess) {
          print('🟢 _LoginSheet: LoginSuccess, token: ${state.loginResponse.data?.token}'); // 🟢 Log
          // 1. إذا رجع التوكن مباشرة (بدون OTP)، نغلق الـ Sheet ونرجع True
          if (state.loginResponse.data?.token != null) {
            print('🟢 _LoginSheet: Token received, popping with true'); // 🟢 Log
            Navigator.pop(context, true);
          }
          // 2. إذا لم يرجع توكن، نفتح شاشة OTP ونغلق شاشة Login
          else {
            print('🟢 _LoginSheet: No token, opening OTP sheet'); // 🟢 Log
            Navigator.pop(context); // إغلاق شاشة Login الحالية
            final verified = await showOtpSheet(
              context,
              phone: _phoneController.text,
              otpCase: OtpCase.verification,
            );
            print('🟢 _LoginSheet: OTP verified: $verified'); // 🟢 Log
            // إذا تم التحقق بنجاح في شاشة OTP، نرجع True للشاشة الرئيسية
            if (verified == true) {
              Navigator.pop(context, true); // إغلاق شاشة OTP
            }
          }
        } else if (state is LoginError) {
          print('🟢 _LoginSheet: LoginError: ${state.error}'); // 🟢 Log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ... عناصر التحكم في العرض (المقبض، العناوين) ...
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorsManager.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                verticalSpace(24),
                Text('قم بتسجيل دخولك الآن',
                    style: TextStyles.font24Black700Weight),
                verticalSpace(8),
                Text('الرجاء تسجيل الدخول لمواصلة التطبيق لدينا',
                    style: TextStyles.font16DarkGrey400Weight),
                verticalSpace(40),
                PhoneTextField(
                  controller: _phoneController,
                  validationError: 'رقم الجوال مطلوب',
                ),
                verticalSpace(20),
                Row(
                  children: [
                    PrimaryCheckBox(
                      onPressed: () =>
                          setState(() => isRememberMe = !isRememberMe),
                      isEnabled: isRememberMe,
                    ),
                    horizontalSpace(4),
                    Text('تذكرني', style: TextStyles.font14DarkGray400Weight),
                  ],
                ),
                verticalSpace(32),
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'تسجيل الدخول',
                      isLoading: state is LoginLoading,
                      onPressed: () {
                        print('🟢 _LoginSheet: Login button pressed, phone: ${_phoneController.text}'); // 🟢 Log
                        if (_formKey.currentState!.validate()) {
                          context.read<LoginCubit>().login(_phoneController.text);
                        }
                      },
                    );
                  },
                ),
                verticalSpace(28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب؟',
                        style: TextStyles.font14DarkGray400Weight),
                    horizontalSpace(8),
                    InkWell(
                      onTap: () async {
                        print('🟢 _LoginSheet: Register button pressed'); // 🟢 Log
                        Navigator.pop(context); // إغلاق شاشة Login
                        final registered = await showRegisterSheet(context);
                        print('🟢 _LoginSheet: Register result: $registered'); // 🟢 Log
                        // إذا تم التسجيل بنجاح، نغلق شاشة Register ونرجع True
                        if (registered == true) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: Text('إنشاء حساب',
                          style: TextStyles.font14Blue500Weight),
                    ),
                  ],
                ),
                verticalSpace(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// ********** شاشة التحقق من OTP (OTP Sheet) **********
// =========================================================================

Future<bool?> showOtpSheet(BuildContext context,
    {required String phone, required OtpCase otpCase}) {
  print('🟢 showOtpSheet: Opening for phone: $phone'); // 🟢 Log
  return _showAppBottomSheet<bool>(
    context: context,
    child: _OtpSheet(phone: phone, otpCase: otpCase),
  ).then((result) {
    print('🟢 showOtpSheet: Closed with result: $result'); // 🟢 Log
    return result;
  });
}

class _OtpSheet extends StatefulWidget {
  final String phone;
  final OtpCase otpCase;
  const _OtpSheet({required this.phone, required this.otpCase});
  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final otpController = TextEditingController();
  String currentText = "";
  Timer? _timer;
  int _start = 120; // 2 دقيقة

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _start = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOtp() {
    print('🟢 _OtpSheet: Verify OTP pressed, code: ${otpController.text}'); // 🟢 Log
    if (otpController.text.length == 4) {
      context.read<OtpCubit>().verifyOtp(
        phoneNumber: widget.phone,
        otp: otpController.text,
        otpCase: widget.otpCase,
      );
    }
  }

  void _resendOtp() {
    print('🟢 _OtpSheet: Resend OTP pressed'); // 🟢 Log
    context.read<OtpCubit>().resendOtp(widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = currentText.length != 4;
    String timerText = _start > 0
        ? '${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}'
        : 'إعادة إرسال';

    return BlocListener<OtpCubit, OtpState>(
      listener: (context, state) {
        print('🟢 _OtpSheet: State changed: $state'); // 🟢 Log
        if (state is OtpVerificationSuccess) {
          print('🟢 _OtpSheet: OtpVerificationSuccess, popping with true'); // 🟢 Log
          // عند نجاح التحقق: نغلق الـ Sheet ونرجع True
          Navigator.pop(context, true);
        } else if (state is OtpVerificationError) {
          print('🟢 _OtpSheet: OtpVerificationError: ${state.error}'); // 🟢 Log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is ResendOtpSuccess) {
          print('🟢 _OtpSheet: ResendOtpSuccess: ${state.message}'); // 🟢 Log
          startTimer(); // إعادة تشغيل المؤقت
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ResendOtpError) {
          print('🟢 _OtpSheet: ResendOtpError: ${state.error}'); // 🟢 Log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... عناصر التحكم في العرض (المقبض، العناوين) ...
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorsManager.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            verticalSpace(24),
            Text('التحقق من OTP', style: TextStyles.font24Black700Weight),
            verticalSpace(8),
            Text(
              'يرجى التحقق من رقمك ${widget.phone} لرؤية رمز التحقق',
              textAlign: TextAlign.center,
              style: TextStyles.font16DarkGrey400Weight,
            ),
            verticalSpace(40),

            // ********** PinCodeTextField **********
            PinCodeTextField(
              controller: otpController,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              appContext: context,
              length: 4,
              autoDisposeControllers: false,
              animationType: AnimationType.fade,
              inputFormatters: [AppInputFormats.numbersFormat],
              keyboardType: TextInputType.number,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.white,
              ),
              animationDuration: const Duration(milliseconds: 300),
              onChanged: (value) {
                setState(() {
                  currentText = value;
                });
              },
              onCompleted: (value) {
                _verifyOtp();
              },
            ),
            // ***************************************************************

            verticalSpace(40),
            BlocBuilder<OtpCubit, OtpState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'تأكيد',
                  isLoading: state is OtpVerificationLoading,
                  isDisabled: isDisabled,
                  onPressed: isDisabled ? () {} : _verifyOtp,
                );
              },
            ),
            verticalSpace(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_start > 0) ...[
                  Text('إعادة إرسال الرمز بعد',
                      style: TextStyles.font14DarkGray400Weight),
                  horizontalSpace(8),
                  Text(timerText, style: TextStyles.font14Blue500Weight),
                ] else ...[
                  BlocBuilder<OtpCubit, OtpState>(
                    builder: (context, state) {
                      return InkWell(
                        onTap: state is ResendOtpLoading ? null : _resendOtp,
                        child: Text(
                          state is ResendOtpLoading ? 'جاري الإرسال...' : 'إعادة إرسال الرمز',
                          style: TextStyles.font14PrimaryColor400Weight,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            verticalSpace(16),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// ********** شاشة إنشاء حساب (REGISTER Sheet) **********
// =========================================================================

Future<bool?> showRegisterSheet(BuildContext context) {
  print('🟢 showRegisterSheet: Opening...'); // 🟢 Log
  return _showAppBottomSheet<bool>(
    context: context,
    child: const _RegisterSheet(),
  ).then((result) {
    print('🟢 showRegisterSheet: Closed with result: $result'); // 🟢 Log
    return result;
  });
}

class _RegisterSheet extends StatefulWidget {
  const _RegisterSheet();
  @override
  State<_RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<_RegisterSheet> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final referral = TextEditingController();
  final email = TextEditingController();
  bool agree = false;

  void _register() {
    print('🟢 _RegisterSheet: Register button pressed'); // 🟢 Log
    if (formKey.currentState!.validate() && agree) {
      final requestBody = RegisterRequestBody(
        username: name.text,
        email: email.text,
        phoneNumber: phone.text,
        referralCode: referral.text,
      );
      context.read<RegisterCubit>().register(requestBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        print('🟢 _RegisterSheet: State changed: $state'); // 🟢 Log
        if (state is RegisterSuccess) {
          print('🟢 _RegisterSheet: RegisterSuccess, opening OTP'); // 🟢 Log
          // عند نجاح التسجيل، نفتح شاشة OTP ونغلق شاشة Register
          Navigator.pop(context); // إغلاق شاشة Register الحالية
          final verified = await showOtpSheet(
            context,
            phone: phone.text,
            otpCase: OtpCase.verification,
          );
          print('🟢 _RegisterSheet: OTP verified: $verified'); // 🟢 Log
          // إذا تم التحقق بنجاح في شاشة OTP، نرجع True للشاشة الرئيسية
          if (verified == true) {
            Navigator.pop(context, true);
          }
        } else if (state is RegisterError) {
          print('🟢 _RegisterSheet: RegisterError: ${state.error}'); // 🟢 Log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ... عناصر التحكم في العرض ...
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorsManager.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              verticalSpace(24),
              Text('إنشاء حساب الآن',
                  style: TextStyles.font24Black700Weight),
              verticalSpace(8),
              Text('يرجى ملء التفاصيل وإنشاء الحساب',
                  style: TextStyles.font16DarkGrey400Weight),
              verticalSpace(40),
              PrimaryTextFormField(
                validationError: 'الاسم مطلوب',
                label: 'الاسم',
                hint: 'الاسم الكامل',
                controller: name,
                prefixIcon:
                const Icon(Icons.person_outline, color: ColorsManager.darkGray),
                fillColor: ColorsManager.dark50,
              ),
              verticalSpace(16),
              PhoneTextField(
                controller: phone,
                validationError: 'رقم الجوال مطلوب',
              ),
              verticalSpace(16),
              PrimaryTextFormField(
                validationError: "رقم الإحالة غير صالح",
                isValidate: false,
                label: "رقم الإحالة (اختياري)",
                controller: referral,
                prefixIcon:
                const Icon(Icons.tag_outlined, color: ColorsManager.darkGray),
                fillColor: ColorsManager.dark50,
              ),
              verticalSpace(16),
              PrimaryTextFormField(
                validationError: 'البريد الإلكتروني مطلوب',
                label: 'البريد الإلكتروني',
                controller: email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon:
                const Icon(Icons.email_outlined, color: ColorsManager.darkGray),
                fillColor: ColorsManager.dark50,
              ),
              verticalSpace(12),
              Row(
                children: [
                  PrimaryCheckBox(
                    onPressed: () => setState(() => agree = !agree),
                    isEnabled: agree,
                  ),
                  horizontalSpace(4),
                  Expanded(
                      child: Text('أوافق على الشروط والأحكام',
                          style: TextStyles.font14DarkGray400Weight)),
                ],
              ),
              verticalSpace(24),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'إنشاء الحساب',
                    isLoading: state is RegisterLoading,
                    isDisabled: !agree,
                    onPressed: _register,
                  );
                },
              ),
              verticalSpace(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('لديك حساب بالفعل؟',
                      style: TextStyles.font14DarkGray400Weight),
                  horizontalSpace(6),
                  InkWell(
                    onTap: () async {
                      print('🟢 _RegisterSheet: Login button pressed'); // 🟢 Log
                      Navigator.pop(context); // إغلاق شاشة Register
                      final loggedIn = await showLoginSheet(context);
                      print('🟢 _RegisterSheet: Login result: $loggedIn'); // 🟢 Log
                      // إذا تم تسجيل الدخول بنجاح، نغلق شاشة Login ونرجع True
                      if (loggedIn == true) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: Text('تسجيل الدخول',
                        style: TextStyles.font14Blue500Weight),
                  )
                ],
              ),
              verticalSpace(20),
            ],
          ),
        ),
      ),
    );
  }
}