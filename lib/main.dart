import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/router/app_router.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
import 'package:mushtary/features/mushtary_client_app.dart';
import 'package:mushtary/generated/codegen_loader.g.dart';

import 'features/messages/data/repo/chat_offline_repository.dart';
import 'features/messages/logic/cubit/chat_cubit.dart';
import 'features/register_service/logic/cubit/service_registration_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // التخزين واللغة
  await CacheHelper.init();
  await EasyLocalization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // DI العادي
  setupServiceLocator();

  // مهم: تسجيل مكونات الشات الأوفلاين + ChatCubit
  await setupChatOfflineLocator();

  // تحقق أثناء التطوير (اختياري)
  assert(getIt.isRegistered<ChatOfflineRepository>(), 'ChatOfflineRepository not registered');
  assert(getIt.isRegistered<ChatCubit>(), 'ChatCubit not registered');

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
            create: (ctx) => getIt<ServiceRegistrationCubit>(),
          ),
        ],
        child: MushtaryClientApp(
          appRouter: AppRouter(),
        ),
      ),
    ),
  );
}