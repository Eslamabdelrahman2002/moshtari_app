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

  /// ✅ التأكد من وجود التوكن، وفتح Bottom Sheet لو مفقود
  Future<String?> ensureToken({bool force = false}) async {
    print('🟢 AuthCoordinator: ensureToken (force=$force)');

    final existing = CacheHelper.getData(key: 'token') as String?;
    if (!force && (existing?.isNotEmpty ?? false)) {
      print('🟢 AuthCoordinator: Existing token found (${existing?.length ?? 0} chars)');
      return existing;
    }

    print('🟢 AuthCoordinator: No valid token, launching auth flow...');

    if (_completer != null) {
      print('🟢 AuthCoordinator: Using existing completer');
      return _completer!.future;
    }
    _completer = Completer<String?>();

    try {
      BuildContext? ctx;
      // 🔹 انتظر لحد ما الـ navigatorKey يبقى جاهز
      for (int i = 0; i < 25; i++) {
        ctx = navigatorKey.currentContext;
        if (ctx != null) break;
        print('🟢 AuthCoordinator: Waiting for valid context...');
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      if (ctx == null) {
        print('🔴 AuthCoordinator: Could not obtain context, aborting flow');
        _completer!.complete(null);
        return null;
      }

      print('🟢 AuthCoordinator: Context ready, opening bottom sheet...');

      // فتح الـ Bottom Sheet داخل الإطار القادم
      await Future<void>.delayed(Duration.zero);
      final flowFinished = await showAuthFlow(ctx);
      print('🟢 AuthCoordinator: showAuthFlow finished: $flowFinished');

      if (!_completer!.isCompleted) {
        if (flowFinished == true) {
          final token = CacheHelper.getData(key: 'token') as String?;
          print('🟢 AuthCoordinator: Flow success, token length ${token?.length ?? 0}');
          _completer!.complete(token);
          return token;
        } else {
          print('🟡 AuthCoordinator: Flow cancelled or failed');
          _completer!.complete(null);
          return null;
        }
      }
      return _completer!.future;
    } catch (e, st) {
      print('🔴 AuthCoordinator: Exception $e\n$st');
      if (!_completer!.isCompleted) _completer!.completeError(e);
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

      // افتح شاشة OTP وانتظر النتيجة
      final ok = await Navigator.pushNamed(ctx, Routes.otpScreen, arguments: args) as bool?;
      if (ok == true) {
        token = CacheHelper.getData(key: 'token') as String?;
      }
    }

    // حفظ التوكن بعد النجاح
    if (token != null && token.isNotEmpty) {
      await CacheHelper.saveData(key: 'token', value: token);
      return token;
    }
    return null;
  }

  Future<void> logout() async {
    await CacheHelper.saveData(key: 'token', value: '');
  }

  /// دالة مختصرة متوافقة مع ApiService
  Future<String?> ensureTokenInteractive() => ensureToken();
}