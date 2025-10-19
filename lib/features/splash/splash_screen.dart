import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'dart:async';
import 'package:mushtary/core/router/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate using named routes after 3 seconds
    Timer(const Duration(seconds: 5), () {
      // Check if the widget is still mounted before navigating
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.onboardingScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.primary500,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // your logo path
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
