import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/router/app_router.dart';
import 'package:mushtary/core/router/app_router.dart' show navigatorKey;
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
import 'package:mushtary/features/mushtary_client_app.dart';
import 'package:mushtary/generated/codegen_loader.g.dart';
import 'core/notification/fcm_service.dart';
import 'features/register_service/logic/cubit/service_registration_cubit.dart';
import 'firebase_options.dart';

Future<void> ensureFirebaseInitialized() async {
  
// لو فيه Default app جاهز، هنستخدمه ونطلع
  try {
    Firebase.app();
    debugPrint('Firebase: default app already available.');
    return;
  } on FirebaseException catch (e) {
    if (e.code != 'no-app') rethrow;
  }


}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await ensureFirebaseInitialized();
// TODO: التعامل مع رسائل الخلفية إن احتجت
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 try{ await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(Platform.isIOS){
    await FirebaseMessaging.instance.getAPNSToken();
  }
  debugPrint('Firebase apps BEFORE ensure: ${Firebase.apps.map((a)=>a.name).toList()}');
}catch(e){
  debugPrint('Firebase apps BEFORE ensure: ${Firebase.apps.map((a)=>a.name).toList()}');
}

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [Locale('ar')],
      useOnlyLangCode: true,
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      assetLoader: const CodegenLoader(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ServiceRegistrationCubit>(
            create: (_) => getIt<ServiceRegistrationCubit>(),
          ),
        ],
        child: MushtaryClientApp(appRouter: AppRouter()),
      ),
    ),
  );
  Future.delayed(Duration.zero,()async{
    // سجّل الهاندلر قبل runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

// اربط الـ navigator للإشعارات
  FcmService.attachNavigator(
    navigatorKey,
    onOpenNotificationRoute: Routes.notificationsScreen,
  );

  await CacheHelper.init();
  await EasyLocalization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  setupServiceLocator();
  // await setupChatOfflineLocator();

  await FcmService.init();

  });
}