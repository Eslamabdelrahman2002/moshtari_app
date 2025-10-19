import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/router/app_router.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/fonts.dart';

// سلوك سحب بدون Glow
class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MushtaryClientApp extends StatefulWidget {
  final AppRouter appRouter;
  const MushtaryClientApp({super.key, required this.appRouter});

  @override
  State<MushtaryClientApp> createState() => _MushtaryClientAppState();
}

class _MushtaryClientAppState extends State<MushtaryClientApp> {
  @override
  void initState() {
    super.initState();
    // إزالة Splash بعد أول فريم لضمان عدم التجمّد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      debugPrint('>> Native splash removed');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mushtary',

          navigatorKey: navigatorKey,
          onGenerateRoute: widget.appRouter.generateRoute,
          initialRoute: Routes.splashScreen,

          // Localization (من EasyLocalization في main)
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // Theme
          theme: ThemeData(
            useMaterial3: false,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            scaffoldBackgroundColor: ColorsManager.white,
            primaryColor: ColorsManager.primaryColor,
            fontFamily: appArabicFontFamily,
            splashColor: ColorsManager.transparent,
            focusColor: ColorsManager.transparent,
            highlightColor: ColorsManager.transparent,
            hoverColor: ColorsManager.transparent,
          ),

          // إزالة Glow الافتراضي
          builder: (context, appChild) {
            return ScrollConfiguration(
              behavior: const _NoGlowBehavior(),
              child: appChild ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}