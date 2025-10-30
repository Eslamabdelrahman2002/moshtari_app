import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/router/app_router.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/fonts.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
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

          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

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