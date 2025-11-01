import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mushtary/core/router/app_router.dart' show navigatorKey;
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
import 'package:mushtary/core/notification/fcm_service.dart';
// Repos
import 'package:mushtary/features/auth/login/data/repo/login_repo.dart';
import 'package:mushtary/features/auth/login/data/models/login_model.dart';
import 'package:mushtary/features/auth/register/data/repo/register_repo.dart';
import 'package:mushtary/features/auth/otp/data/repo/otp_repo.dart';
import '../../features/auth/otp/ui/screens/otp_screen_args.dart';
import '../enums/otp_case.dart';
import '../router/routes.dart';
import '../widgets/primary/auth_bottom_sheets.dart';

class AuthCoordinator {
  final LoginRepo _loginRepo;
  final RegisterRepo? _registerRepo;
  final OtpRepo? _otpRepo;

  Completer<String?>? _completer;

  AuthCoordinator({
    required LoginRepo loginRepo,
    RegisterRepo? registerRepo,
    OtpRepo? otpRepo,
  })  : _loginRepo = loginRepo,
        _registerRepo = registerRepo,
        _otpRepo = otpRepo;

  Future<String?> ensureToken({bool force = false}) async {
    print('🟢 AuthCoordinator: ensureToken called (force: $force)'); // 🟢 Log للـ debug

    final existing = CacheHelper.getData(key: 'token') as String?;
    // لو عندنا توكن صالح، نرجعه ونكمل
    if (!force && (existing?.isNotEmpty ?? false)) {
      print('🟢 AuthCoordinator: Existing token found (${existing?.length ?? 0} chars)'); // 🟢 Log
      return existing;
    }

    print('🟢 AuthCoordinator: No valid token, starting flow'); // 🟢 Log

    if (_completer != null) {
      print('🟢 AuthCoordinator: Using existing completer'); // 🟢 Log
      return _completer!.future;
    }
    _completer = Completer<String?>();

    try {
      final ctx = navigatorKey.currentContext;
      print('🟢 AuthCoordinator: Context available: ${ctx != null}'); // 🟢 Log

      if (ctx == null) {
        print('🟢 AuthCoordinator: Context null, retrying in 100ms'); // 🟢 Log
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return ensureToken(force: force);
      }

      print('🟢 AuthCoordinator: Scheduling showAuthFlow...'); // 🟢 Log

      // نفتح Auth Flow بالكامل عبر Bottom Sheets
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          print('🟢 AuthCoordinator: Calling showAuthFlow'); // 🟢 Log
          // يتم فتح التدفق بالكامل هنا (Login -> OTP -> Register)
          final flowFinished = await showAuthFlow(ctx);

          print('🟢 AuthCoordinator: showAuthFlow finished: $flowFinished'); // 🟢 Log

          // 🟢 تصحيح Null Safety: check لو _completer موجود قبل استخدام !
          if (_completer != null && !_completer!.isCompleted) {
            // إذا نجح التدفق، يعني أن التوكن تم حفظه
            if (flowFinished == true) {
              final token = CacheHelper.getData(key: 'token') as String?;
              print('🟢 AuthCoordinator: Flow success, token: ${token?.length ?? 0} chars'); // 🟢 Log
              _completer!.complete(token);
            } else {
              print('🟢 AuthCoordinator: Flow failed/cancelled (${flowFinished})'); // 🟢 Log
              _completer!.complete(null);
            }
          } else {
            print('🟢 AuthCoordinator: Completer already completed or null'); // 🟢 Log
          }
        } catch (e) {
          print('🟢 AuthCoordinator: Error in showAuthFlow: $e'); // 🟢 Log
          if (_completer != null && !_completer!.isCompleted) {
            _completer!.completeError(e);
          }
        }
      });
      return _completer!.future;
    } catch (e) {
      print('🟢 AuthCoordinator: Outer error: $e'); // 🟢 Log
      if (_completer != null && !_completer!.isCompleted) {
        _completer!.completeError(e);
      }
      rethrow;
    } finally {
      _completer = null;
    }
  }

  /// تنفيذ تسلسل تسجيل الدخول + OTP داخل الشيتات نفسها
  Future<String?> _handleLoginFlow(
      BuildContext ctx, Map<String, dynamic>? loginRes) async {
    if (loginRes == null) return null;
    final action = loginRes['action'] as String?;

    // المستخدم اختار "إنشاء حساب"
    if (action == 'register') {
      final bool? done = await showRegisterSheet(ctx);
      return done == true
          ? CacheHelper.getData(key: 'token') as String?
          : null;
    }

    // المستخدم اختار "تسجيل الدخول"
    final phone = (loginRes['phone'] as String?)?.trim() ?? '';
    if (phone.isEmpty) return null;

    final fcm = await FcmService.currentToken();
    final loginResponse = await _loginRepo.login(
      LoginRequestBody(phoneNumber: phone),
      fcmToken: fcm,
    );

    var token = loginResponse.data?.token;

    // السيرفر رجَّع "محتاج OTP"
    if (token == null || token.isEmpty) {
      final args = OtpScreenArgs(
        phoneNumber: phone,
        otpCase: OtpCase.verification,
      );

// افتح شاشة الـ OTP الكاملة وانتظر النتيجة
      final ok =
      await Navigator.pushNamed(ctx, Routes.otpScreen, arguments: args) as bool?;

      if (ok == true) {
        token = CacheHelper.getData(key: 'token') as String?;
      }
    }

    // حفظ التوكن بعد نجاح أي طريقة
    if (token != null && token.isNotEmpty) {
      await CacheHelper.saveData(key: 'token', value: token);
      return token;
    }
    return null;
  }

  Future<void> logout() async {
    await CacheHelper.saveData(key: 'token', value: '');
  }

  // 🟢 دالة متوافقة مع EnsureTokenInteractive (إضافة جديدة)
  Future<String?> ensureTokenInteractive() => ensureToken();
}