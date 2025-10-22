import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // وقت بسيط لإظهار الشعار
    await Future.delayed(const Duration(seconds: 2));

    final token = CacheHelper.getData(key: 'token') as String?;
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // مستخدم مسجّل دخول
      Navigator.pushReplacementNamed(context, Routes.bottomNavigationBar);
    } else {
      // أول مرة أو غير مسجل دخول
      Navigator.pushReplacementNamed(context, Routes.onboardingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.primary500,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}