// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Routes & DI
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

// Helpers
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

// Auth
import 'package:mushtary/features/auth/login/ui/screens/login_screen.dart';
import 'package:mushtary/features/auth/otp/ui/screens/otp_screen.dart';
import 'package:mushtary/features/auth/otp/ui/screens/otp_screen_args.dart';
import 'package:mushtary/features/auth/register/ui/screens/register_screen.dart';
import 'package:mushtary/features/auth/register/ui/screens/complete_profile_screen.dart';
import 'package:mushtary/features/auth/reset_password/data/model/reset_password_args.dart';
import 'package:mushtary/features/auth/reset_password/ui/screens/forget_password_screen.dart';
import 'package:mushtary/features/auth/reset_password/ui/screens/reset_password_screen.dart';

// BottomNav/Home
import 'package:mushtary/features/home/ui/screens/bottom_navigation_bar.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/ui/screens/home_screen.dart';
import 'package:mushtary/features/home/ui/widgets/home_reels_view.dart';

// Common
import 'package:mushtary/features/splash/splash_screen.dart';
import 'package:mushtary/features/onboarding/ui/screens/onboarding_screen.dart';
import 'package:mushtary/features/favorites/ui/screens/favorites_screen.dart';
import 'package:mushtary/features/settings/ui/screens/languages_screen.dart';
import 'package:mushtary/features/support/ui/screens/technical_support_screen.dart';
import 'package:mushtary/features/wallet/ui/screens/wallet_screen.dart';
import 'package:mushtary/features/earnings/ui/screens/earnings_screen.dart';
import 'package:mushtary/features/notifications/ui/screens/notifications_screen.dart';
import 'package:mushtary/features/commission_calculator/ui/screens/commission_calculator_screen.dart';

// Menu
import 'package:mushtary/features/menu/data/menu_screen_args.dart';
import 'package:mushtary/features/menu/screens/menu_screen.dart';

// Profile
import 'package:mushtary/features/user_profile/ui/user_profile_screen.dart';
import 'package:mushtary/features/user_profile/ui/update_profile_screen.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

// Real estate
import 'package:mushtary/features/real_estate/ui/screens/real_estate_screen.dart';
import 'package:mushtary/features/real_estate/data/model/mock_data.dart' hide MessagesModel;
import 'package:mushtary/features/real_estate_details/ui/screens/real_estate_details_screen.dart';
import 'package:mushtary/features/real_estate_details/logic/cubit/real_estate_details_cubit.dart';

// Real estate applications
import 'package:mushtary/features/real_estate_applications_deatils/screens/real_estate_applications_details_screen.dart';

// Product details
import 'package:mushtary/features/product_details/ui/screens/car_details_screen.dart';
import 'package:mushtary/features/product_details/ui/screens/car_part_details_screen.dart';
import 'package:mushtary/features/product_details/ui/screens/other_ad_details_screen.dart';
import 'package:mushtary/features/product_details/ui/screens/car_auction_details_screen.dart';
import 'package:mushtary/features/product_details/ui/screens/real_estate_auction_details_screen.dart';

// Create flows
import 'package:mushtary/features/create_ad/ui/screens/create_ad_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_create_ad_flow.dart';
import 'package:mushtary/features/create_ad/ui/screens/auction_category_picker_screen.dart';
import 'package:mushtary/features/ad_action/ui/screens/car_auction_start_screen.dart';
import 'package:mushtary/features/ad_action/ui/screens/real_estate_auction_start_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/publish_entry_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/cars/cars_advanced_details_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/cars/cars_display_information_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/cars/logic/cubit/car_ads_cubit.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_cubit.dart';
import 'package:mushtary/features/create_ad/ui/screens/other/logic/cubit/other_ads_cubit.dart';
import 'package:mushtary/features/create_ad/ui/screens/car_parts/logic/cubit/car_part_ads_cubit.dart';
import 'package:mushtary/features/create_ad/ui/screens/other/other_ad_selects_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/other/other_ad_view_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/car_parts/car_part_create_ad_step1_screen.dart';
import 'package:mushtary/features/create_ad/ui/screens/car_parts/car_part_create_ad_step2_screen.dart';

// Chat
import 'package:mushtary/features/messages/ui/screens/chat_screen.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';

import '../../features/register_service/dyna/ui/screens/CompleteProfileScreenSteps.dart';
import '../../features/register_service/flatbed/ui/screens/delivery_service_steps.dart';
import '../../features/register_service/labour/ui/screens/complete_profile_screen_steps.dart';
import '../../features/register_service/tanker/ui/screens/tanker_service_steps.dart';
import '../../features/service_profile/ui/screens/service_provider_dashboard_screen.dart';
import '../../features/service_request/ui/screens/my_received_offers_screen.dart';
import '../../features/services/ui/screens/worker_detail_screen.dart';
import '../../features/trips/ui/screens/dyna_my_trips_screen.dart';
import '../../features/trips/ui/screens/dyna_trip_create_screen.dart';
import '../../features/trips/ui/screens/dyna_trips_manager_screen.dart';
import '../../features/trips/ui/screens/dyna_trips_screen.dart';
import '../../features/work_with_us/ui/screens/work_with_us_form_screen.dart';
import '../../features/work_with_us/ui/screens/work_with_us_intro_screen.dart';

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static Future<void> goToBottomNavAsRoot() async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.bottomNavigationBar,
          (route) => false,
    );
  }

  Route generateRoute(RouteSettings settings) {
    // ignore: avoid_print
    print(">>>> Route called: ${settings.name}, args: ${settings.arguments}");
    final arguments = settings.arguments;

    switch (settings.name) {
    // Splash / Onboarding / Auth
      case Routes.splashScreen:
        return NoAnimationPageRoute(builder: (_) => const SplashScreen());

      case Routes.onboardingScreen:
        return NoAnimationPageRoute(builder: (_) => const OnboardingScreen());

      case Routes.loginScreen:
        return NoAnimationPageRoute(builder: (_) => const LoginScreen());

      case Routes.registerScreen:
        return NoAnimationPageRoute(builder: (_) => const RegisterScreen());

      case Routes.otpScreen:
        return NoAnimationPageRoute(
          builder: (_) => OtpScreen(otpScreenArgs: arguments as OtpScreenArgs),
        );

      case Routes.forgetPasswordScreen:
        return NoAnimationPageRoute(builder: (_) => const ForgetPasswordScreen());

      case Routes.resetPasswordScreen: {
        final args = arguments as ResetPasswordArgs;
        return NoAnimationPageRoute(
          builder: (_) => ResetPasswordScreen(
            phoneNumber: args.phoneNumber,
            otp: args.otp,
          ),
        );
      }

    // BottomNav + Home
      case Routes.bottomNavigationBar:
        return NoAnimationPageRoute(builder: (_) => const MushtaryBottomNavigationBar());

      case Routes.createAdScreen:
        return NoAnimationPageRoute(builder: (_) => const CreateAdScreen());

    // Content
      case Routes.reelsScreen:
        return NoAnimationPageRoute(
          builder: (_) => HomeReelsView(ads: arguments as List<HomeAdModel>),
        );

    // User / Settings
      case Routes.userProfileScreen:
        return NoAnimationPageRoute(builder: (_) => const UserProfileScreen());

      case Routes.updateProfileScreen: {
        final cubit = getIt<ProfileCubit>();
        return NoAnimationPageRoute(
          builder: (_) => BlocProvider.value(value: cubit, child: UpdateProfileScreen()),
        );
      }

      case Routes.languagesScreen:
        return NoAnimationPageRoute(builder: (_) => const LanguagesScreen());

      case Routes.completeProfileScreen:
        return NoAnimationPageRoute(builder: (_) => const CompleteProfileScreen());

      case Routes.earningsScreen:
        return NoAnimationPageRoute(builder: (_) => const EarningsScreen());

      case Routes.favoritesScreen:
        return NoAnimationPageRoute(builder: (_) => const FavoritesScreen());

      case Routes.technicalSupportScreen:
        return NoAnimationPageRoute(builder: (_) => const TechnicalSupportScreen());

      case Routes.walletScreen:
        return NoAnimationPageRoute(builder: (_) => const WalletScreen());

      case Routes.commissionCalculatorScreen:
        return NoAnimationPageRoute(builder: (_) => const CommissionCalculatorScreen());

    // Menu with safe args
      case Routes.menuScreen: {
        final args = settings.arguments;
        MenuScreenArgs menuArgs;
        if (args is MenuScreenArgs) {
          menuArgs = args;
        } else {
          final token = CacheHelper.getData(key: 'token') as String?;
          final isAuth = token != null && token.isNotEmpty;

          menuArgs = MenuScreenArgs(
            isAuthenticated: isAuth,
            onProfileTap: () => navigatorKey.currentState?.pushNamed(Routes.userProfileScreen),
            onLoginTap: () => navigatorKey.currentState?.pushNamed(Routes.loginScreen),
            onLogout: () async {
              await CacheHelper.removeData(key: 'token');
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                Routes.bottomNavigationBar,
                    (r) => false,
              );
            },
          );
        }
        return NoAnimationPageRoute(
          builder: (_) => MenuScreen(menuScreenArgs: menuArgs),
        );
      }

    // Product details
      case Routes.carDetailsScreen: {
        final id = _asInt(arguments);
        return NoAnimationPageRoute(builder: (_) => CarDetailsScreen(id: id));
      }

      case Routes.carPartDetailsScreen: {
        final id = _asInt(arguments);
        return NoAnimationPageRoute(builder: (_) => CarPartDetailsScreen(id: id));
      }

      case Routes.otherAdDetailsScreen: {
        final id = _asInt(arguments);
        return NoAnimationPageRoute(builder: (_) => OtherAdDetailsScreen(id: id));
      }

      case Routes.carAuctionDetailsScreen: {
        final id = _asInt(arguments);
        return NoAnimationPageRoute(builder: (_) => CarAuctionDetailsScreen(id: id));
      }

      case Routes.realEstateAuctionDetailsScreen: {
        final id = _asInt(arguments);
        return NoAnimationPageRoute(builder: (_) => RealEstateAuctionDetailsScreen(id: id));
      }

    // Real estate
      case Routes.realEstateScreen:
        return NoAnimationPageRoute(builder: (_) => const RealEstateScreen());

      case Routes.realEstateApplicationsDetailsScreen:
        return NoAnimationPageRoute(
          builder: (_) => RealEstateApplicationsDetailsScreen(
            realStateApplicationsDetailsModel: arguments as RealStateApplicationsDetailsModel,
          ),
        );

      case Routes.realEstateDetailsScreen: {
        final id = _asInt(arguments);
        return NoAnimationPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<RealEstateDetailsCubit>()..getRealEstateDetails(id),
            child: RealEstateDetailsScreen(id: id),
          ),
        );
      }


    // Real estate create ad flow
      case Routes.createRealEstateAdFlow:
        return NoAnimationPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<RealEstateAdsCubit>(create: (context) => getIt<RealEstateAdsCubit>()),
            ],
            child: const RealEstateCreateAdFlow(),
          ),
        );

    // Car parts create ad flow
      case Routes.createCarPartAdScreen:
        return NoAnimationPageRoute(
          builder: (_) => BlocProvider<CarPartAdsCubit>(
            create: (context) => getIt<CarPartAdsCubit>(),
            child: const CarPartCreateAdStep1Screen(),
          ),
        );

      case Routes.createCarPartAdStep1:
        return NoAnimationPageRoute(
          builder: (_) => BlocProvider<CarPartAdsCubit>(
            create: (context) => getIt<CarPartAdsCubit>(),
            child: const CarPartCreateAdStep1Screen(),
          ),
        );

      case Routes.createCarPartAdStep2: {
        final arg = settings.arguments;
        if (arg is CarPartAdsCubit) {
          return NoAnimationPageRoute(
            builder: (_) => BlocProvider<CarPartAdsCubit>.value(
              value: arg,
              child: const CarPartCreateAdStep2Screen(),
            ),
          );
        }
        return NoAnimationPageRoute(
          builder: (_) => BlocProvider<CarPartAdsCubit>(
            create: (context) => getIt<CarPartAdsCubit>(),
            child: const CarPartCreateAdStep2Screen(),
          ),
        );
      }

    // Other create ad flow
      case Routes.createOtherAdStep1:
        return NoAnimationPageRoute(
          builder: (_) => BlocProvider<OtherAdsCubit>(
            create: (context) => getIt<OtherAdsCubit>(),
            child: Builder(
              builder: (ctx) => OtherAdSelectsScreen(
                onNext: () {
                  final cubit = ctx.read<OtherAdsCubit>();
                  navigatorKey.currentState?.pushNamed(
                    Routes.createOtherAdStep2,
                    arguments: cubit,
                  );
                },
              ),
            ),
          ),
        );

      case Routes.createOtherAdStep2: {
        final arg = settings.arguments;
        if (arg is OtherAdsCubit) {
          return NoAnimationPageRoute(
            builder: (_) => BlocProvider<OtherAdsCubit>.value(
              value: arg,
              child: const OtherAdViewScreen(),
            ),
          );
        }
        return NoAnimationPageRoute(
          builder: (_) => BlocProvider<OtherAdsCubit>(
            create: (context) => getIt<OtherAdsCubit>(),
            child: const OtherAdViewScreen(),
          ),
        );
      }

    // Auctions (create)
      case Routes.createCarAuctionScreen:
        return NoAnimationPageRoute(builder: (_) => const CarAuctionStartScreen());

      case Routes.createRealEstateAuctionScreen:
        return NoAnimationPageRoute(builder: (_) => const RealEstateAuctionStartScreen());

      case Routes.publishEntryScreen:
        return NoAnimationPageRoute(builder: (_) => const PublishEntryScreen());

      case Routes.auctionCategoryPickerScreen:
        return NoAnimationPageRoute(builder: (_) => const AuctionCategoryPickerScreen());

    // Chat
      case Routes.chatScreen:
        final arg = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(args: arg), // يقبل MessagesModel أو ChatScreenArgs
        );

    // Notifications
      case Routes.notificationsScreen:
        return NoAnimationPageRoute(builder: (_) => const NotificationsScreen());

    // Workers
      case Routes.workerDetailsScreen:
      // افترض إن settings.arguments هو int (providerId) أو Map مع 'providerId'
        final int providerId = settings.arguments is int
            ? settings.arguments as int
            : (settings.arguments is Map ? (settings.arguments as Map)['providerId'] ?? 0 : 0); // default إذا null
        return NoAnimationPageRoute(
          builder: (_) => WorkerDetailsScreen(providerId: providerId), // مرر providerId هنا
        );
      case Routes.completeProfileSteps:
      // شاشة اجير (Worker/General)
        return NoAnimationPageRoute(builder: (_) => const CompleteProfileScreenSteps());

      case Routes.transportServiceSteps:
      // شاشة دينات (Transport)
        return NoAnimationPageRoute(builder: (_) => const TransportServiceProviderSteps());

      case Routes.deliveryServiceSteps:
      // شاشة سطحة (Delivery/Satha)
        return NoAnimationPageRoute(builder: (_) => const DeliveryServiceSteps());

      case Routes.tankerServiceSteps:
      // شاشة صهريج (Tanker)
        return NoAnimationPageRoute(builder: (_) => const TankerServiceSteps());
    // Work with us
      case Routes.workWithUsIntroScreen:
        return NoAnimationPageRoute(builder: (_) => const WorkWithUsIntroScreen());

      case Routes.workWithUsFormScreen:
        return NoAnimationPageRoute(builder: (_) => const WorkWithUsFormScreen());

    //trips
      case Routes.createDynaTripScreen: {
        final providerId = _asInt(settings.arguments);
        return NoAnimationPageRoute(
          builder: (_) => CreateDynaTripScreen(providerId: providerId),
        );
      }
      case Routes.dynaMyTripsScreen:
        return NoAnimationPageRoute(builder: (_) => const DynaMyTripsScreen());
      case Routes.dynaTripsScreen:
        return NoAnimationPageRoute(builder: (_) => const DynaTripsScreen());
      case Routes.dynaTripsManagerScreen:
        return NoAnimationPageRoute(builder: (_) => const DynaTripsManagerScreen());
      case Routes.serviceProviderDashboard: {
        final providerId = _asInt(settings.arguments);
        return NoAnimationPageRoute(
          builder: (_) => ServiceProviderDashboardScreen(providerId: providerId),
        );
      }
      case Routes.myReceivedOffersScreen:
        return NoAnimationPageRoute(builder: (_) => const MyReceivedOffersScreen());

    // Default
      default:
        return NoAnimationPageRoute(builder: (_) => const HomeScreen());
    }
  }

  int _asInt(Object? arg) {
    if (arg is int) return arg;
    if (arg is String) {
      final v = int.tryParse(arg);
      if (v != null) return v;
    }
    // ignore: avoid_print
    print('>>> [Router] Expected int id but got: $arg (${arg.runtimeType}) — defaulting to 0');
    return 0;
  }
}