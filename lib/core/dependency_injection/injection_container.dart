// lib/core/dependency_injection/injection_container.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mushtary/core/location/data/repo/location_repo.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';

// Create Ads
import 'package:mushtary/features/create_ad/data/car/data/repo/car_ads_repository.dart';
import 'package:mushtary/features/create_ad/ui/screens/cars/logic/cubit/car_ads_cubit.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_cubit.dart';
import 'package:mushtary/features/create_ad/data/car/data/repo/real_estate_ads_repo.dart';
import 'package:mushtary/features/create_ad/data/car/data/repo/car_part_ads_create_repo.dart';
import 'package:mushtary/features/create_ad/ui/screens/car_parts/logic/cubit/car_part_ads_cubit.dart';
import 'package:mushtary/features/create_ad/data/car/data/repo/other_ads_repo.dart'; // 🟢 تم تحديث الاستيراد
import 'package:mushtary/features/create_ad/ui/screens/other/logic/cubit/other_ads_cubit.dart'; // 🟢 تم تحديث الاستيراد

// Auth
import 'package:mushtary/features/auth/login/data/repo/login_repo.dart';
import 'package:mushtary/features/auth/login/logic/cubit/login_cubit.dart';
import 'package:mushtary/features/auth/otp/data/repo/otp_repo.dart';
import 'package:mushtary/features/auth/otp/cubit/otp_cubit.dart';
import 'package:mushtary/features/auth/register/data/repo/register_repo.dart';
import 'package:mushtary/features/auth/register/logic/cubit/refister_cubit.dart';
import 'package:mushtary/features/auth/reset_password/data/repo/forget_password_repo.dart';
import 'package:mushtary/features/auth/reset_password/data/repo/reset_password_repo.dart';
import 'package:mushtary/features/auth/reset_password/ui/logic/cubit/forget_password_cubit.dart';
import 'package:mushtary/features/auth/reset_password/ui/logic/cubit/reset_password_cubit.dart';

// Home/Favorites
import 'package:mushtary/features/home/data/repo/home_repo.dart';
import 'package:mushtary/features/home/logic/cubit/home_cubit.dart';
import 'package:mushtary/features/favorites/data/repo/favorites_repo.dart';
import 'package:mushtary/features/favorites/ui/logic/cubit/favorites_cubit.dart';

// Profile
import 'package:mushtary/features/user_profile/data/repo/profile_repo.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

// Product details
import 'package:mushtary/features/product_details/data/repo/car_details_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/car_details_cubit.dart';
import 'package:mushtary/features/product_details/data/repo/car_parts_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/car_parts_details_cubit.dart';
import 'package:mushtary/features/product_details/data/repo/other_ads_repo.dart' as pd_other;
import 'package:mushtary/features/product_details/ui/logic/cubit/other_ad_details_cubit.dart';
import 'package:mushtary/features/product_details/data/repo/car_auction_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/car_auction_details_cubit.dart';
import 'package:mushtary/features/product_details/data/repo/real_estate_auction_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/real_estate_auction_details_cubit.dart';
import 'package:mushtary/features/product_details/data/repo/ad_reviews_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/comment_send_cubit.dart';
import 'package:mushtary/features/product_details/data/repo/marketing_requests_repo.dart';
import 'package:mushtary/features/product_details/ui/logic/cubit/marketing_request_cubit.dart';
// Real estate domain
import 'package:mushtary/features/real_estate/data/repo/real_estate_repo.dart';
import 'package:mushtary/features/real_estate/logic/cubit/real_estate_cubit.dart';
import 'package:mushtary/features/real_estate_details/logic/cubit/real_estate_details_cubit.dart' as reDetailsCubit;

// Auctions start
import 'package:mushtary/features/ad_action/data/repo/car_auction_start_repo.dart';
import 'package:mushtary/features/ad_action/data/repo/real_estate_auction_start_repo.dart';
import 'package:mushtary/features/ad_action/ui/logic/cubit/car_auction_start_cubit.dart';
import 'package:mushtary/features/ad_action/ui/logic/cubit/real_estate_auction_start_cubit.dart';

// Chat
import 'package:mushtary/features/messages/data/repo/chat_socket_service.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/logic/cubit/messages_cubit.dart';
import 'package:mushtary/features/messages/logic/cubit/chat_cubit.dart';
import 'package:mushtary/features/work_with_us/data/repo/promoter_profile_repo.dart';

// Core
import '../../features/commission_calculator/data/repo/commission_repo.dart';
import '../../features/commission_calculator/ui/logic/cubit/commission_cubit.dart';
import '../../features/product_details/data/repo/auction_bid_repo.dart';
import '../../features/product_details/data/repo/auction_socket_service.dart';
import '../../features/product_details/data/repo/offers_repo.dart';
import '../../features/product_details/ui/logic/cubit/auction_bid_cubit.dart';
import '../../features/product_details/ui/logic/cubit/offer_cubit.dart';
import '../../features/product_details/ui/widgets/full_view_widget/comments_bottom_sheet.dart';
import '../../features/register_service/data/repo/service_registration_repo.dart';
import '../../features/register_service/logic/cubit/service_registration_cubit.dart';
import '../../features/service_profile/data/repo/service_provider_repo.dart';
import '../../features/service_profile/ui/logic/cubit/provider_cubit.dart';
import '../../features/service_request/data/repo/provider_repo.dart' as pr;
import '../../features/service_request/data/repo/received_offers_repo.dart' as ro;
import '../../features/service_request/ui/logic/cubit/provider_cubit.dart' as poc;
import '../../features/service_request/ui/logic/cubit/received_offers_cubit.dart' as roc;
// ❌ تم إزالة الاستيراد التالي: import '../../features/services/data/repo/dyna_trip_repo.dart';
import '../../features/services/data/repo/laborer_types_repo.dart';
import '../../features/services/data/repo/service_offers_repo.dart';
import '../../features/services/data/repo/service_providers_repo.dart';
import '../../features/services/data/repo/service_request_repo.dart';
import '../../features/services/logic/cubit/dyna_trips_cubit.dart';
import '../../features/services/logic/cubit/laborer_types_cubit.dart';
import '../../features/services/logic/cubit/service_offer_cubit.dart';
import '../../features/services/logic/cubit/service_providers_cubit.dart';
import '../../features/services/logic/cubit/service_request_cubit.dart';
import '../../features/support/data/repo/conversation_report_repo.dart';
import '../../features/support/ui/logic/conversation_report_cubit.dart';
import '../../features/trips/data/repo/dyna_trips_repo.dart'; // ✅ هذا هو المستودع المدمج الآن
import '../../features/trips/ui/logic/cubit/dyna_my_trips_cubit.dart';
import '../../features/trips/ui/logic/cubit/dyna_trip_create_cubit.dart';
import '../../features/trips/ui/logic/cubit/dyna_trips_list_cubit.dart';
import '../../features/user_profile/data/repo/ads_repo.dart';
import '../../features/user_profile/data/repo/my_auctions_repo.dart';
import '../../features/wallet/ui/data/repo/payment_config_repo.dart';
import '../../features/work_with_us/data/repo/exhibition_create_repo.dart';
import '../../features/work_with_us/data/repo/exhibition_details_repo.dart';
import '../../features/work_with_us/data/repo/exhibitions_repo.dart';
import '../../features/work_with_us/data/repo/work_with_us_repo.dart';
import '../../features/work_with_us/ui/logic/cubit/exhibition_create_cubit.dart';
import '../../features/work_with_us/ui/logic/cubit/exhibition_details_cubit.dart';
import '../../features/work_with_us/ui/logic/cubit/exhibitions_cubit.dart';
import '../../features/work_with_us/ui/logic/cubit/promoter_profile_cubit.dart';
import '../../features/work_with_us/ui/logic/cubit/work_with_us_cubit.dart';
import '../api/api_constants.dart';
import '../api/api_service.dart' as api;
import '../car/data/repo/car_catalog_repo.dart';
import '../car/logic/cubit/car_catalog_cubit.dart';
import '../utils/helpers/cache_helper.dart';

// GetIt
final getIt = GetIt.instance;

// Helpers to avoid duplicate registrations
void registerLazyIfNeeded<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory);
  }
}

void registerFactoryReplacing<T extends Object>(T Function() factory) {
  if (getIt.isRegistered<T>()) {
    getIt.unregister<T>();
  }
  getIt.registerFactory<T>(factory);
}

void setupServiceLocator() {
  // Dio & ApiService
  registerLazyIfNeeded<Dio>(() => Dio());
  registerLazyIfNeeded<api.ApiService>(() => api.ApiService(getIt<Dio>()));

  // Auth
  registerLazyIfNeeded<LoginRepo>(() => LoginRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<LoginCubit>(() => LoginCubit(getIt<LoginRepo>()));
  registerLazyIfNeeded<RegisterRepo>(() => RegisterRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<RegisterCubit>(() => RegisterCubit(getIt<RegisterRepo>()));
  registerLazyIfNeeded<OtpRepo>(() => OtpRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<OtpCubit>(() => OtpCubit(getIt<OtpRepo>()));
  registerLazyIfNeeded<ForgetPasswordRepo>(() => ForgetPasswordRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ForgetPasswordCubit>(() => ForgetPasswordCubit(getIt<ForgetPasswordRepo>()));
  registerLazyIfNeeded<ResetPasswordRepo>(() => ResetPasswordRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ResetPasswordCubit>(() => ResetPasswordCubit(getIt<ResetPasswordRepo>()));

  // Home
  registerLazyIfNeeded<HomeRepo>(() => HomeRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<HomeCubit>(() => HomeCubit(getIt<HomeRepo>()));

  // Favorites
  registerLazyIfNeeded<FavoritesRepo>(() => FavoritesRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<FavoritesCubit>(() => FavoritesCubit(getIt<FavoritesRepo>()));

  // Product details
  registerLazyIfNeeded<CarDetailsRepo>(() => CarDetailsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<CarDetailsCubit>(() => CarDetailsCubit(getIt<CarDetailsRepo>()));

  registerLazyIfNeeded<CarPartsRepo>(() => CarPartsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<CarPartsDetailsCubit>(() => CarPartsDetailsCubit(getIt<CarPartsRepo>()));

  registerLazyIfNeeded<pd_other.OtherAdsRepo>(() => pd_other.OtherAdsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<OtherAdDetailsCubit>(() => OtherAdDetailsCubit(getIt<pd_other.OtherAdsRepo>()));

  registerLazyIfNeeded<CarAuctionRepo>(() => CarAuctionRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<CarAuctionDetailsCubit>(() => CarAuctionDetailsCubit(getIt<CarAuctionRepo>()));

  registerLazyIfNeeded<RealEstateAuctionRepo>(() => RealEstateAuctionRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<RealEstateAuctionDetailsCubit>(() => RealEstateAuctionDetailsCubit(getIt<RealEstateAuctionRepo>()));

  // Real estate
  registerLazyIfNeeded<RealEstateRepo>(() => RealEstateRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<RealEstateCubit>(() => RealEstateCubit(getIt<RealEstateRepo>()));
  registerFactoryReplacing<reDetailsCubit.RealEstateDetailsCubit>(
        () => reDetailsCubit.RealEstateDetailsCubit(getIt<RealEstateRepo>()),
  );

  // Create ads
  registerLazyIfNeeded<CarPartAdsCreateRepo>(() => CarPartAdsCreateRepo(getIt<Dio>()));
  registerFactoryReplacing<CarPartAdsCubit>(() => CarPartAdsCubit(getIt<CarPartAdsCreateRepo>()));

  registerLazyIfNeeded<CarAdsRepository>(() => CarAdsRepository(getIt<api.ApiService>()));
  registerFactoryReplacing<CarAdsCubit>(() => CarAdsCubit(getIt<CarAdsRepository>()));

  registerLazyIfNeeded<RealEstateAdsRepo>(() => RealEstateAdsRepo(getIt<Dio>()));
  registerFactoryReplacing<RealEstateAdsCubit>(() => RealEstateAdsCubit(getIt<RealEstateAdsRepo>()));

  // 🟢 تسجيل OtherAds Create Repo و Cubit
  registerLazyIfNeeded<OtherAdsCreateRepo>(() => OtherAdsCreateRepo(getIt<Dio>())); // OtherAdsCreateRepo هو اسم الملف
  registerFactoryReplacing<OtherAdsCubit>(() => OtherAdsCubit(getIt<OtherAdsCreateRepo>())); // 🟢 تم تسجيل OtherAdsCubit

  // Profile
  registerLazyIfNeeded<ProfileRepo>(() => ProfileRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ProfileCubit>(() => ProfileCubit(getIt<ProfileRepo>()));

  // Reviews & Marketing
  registerLazyIfNeeded<AdReviewsRepo>(() => AdReviewsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<CommentSendCubit>(() => CommentSendCubit(getIt<AdReviewsRepo>()));

  registerLazyIfNeeded<MarketingRequestsRepo>(() => MarketingRequestsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<MarketingRequestCubit>(() => MarketingRequestCubit(getIt<MarketingRequestsRepo>()));

  registerLazyIfNeeded<CarAuctionStartRepo>(() => CarAuctionStartRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<CarAuctionStartCubit>(() => CarAuctionStartCubit(getIt<CarAuctionStartRepo>()));

  registerLazyIfNeeded<RealEstateAuctionStartRepo>(() => RealEstateAuctionStartRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<RealEstateAuctionStartCubit>(() => RealEstateAuctionStartCubit(getIt<RealEstateAuctionStartRepo>()));

  // Chat WebSocket
  getIt.registerLazySingleton<ChatSocketService>(() => ChatSocketService(
    tokenProvider: () => CacheHelper.getData(key: 'token') as String?,
    host: ApiConstants.wsHost,
    path: '/socket.io',
    secure: false,
  ));

  // Auction WebSocket + بث التحديث على الكيوبت الصحيح بالاسم "type-auctionId"
  getIt.registerLazySingleton<AuctionSocketService>(() => AuctionSocketService(
    host: ApiConstants.wsHost,
    secure: false,
    onMaxBidUpdate: (maxBid, type, auctionId) {
      final key = '$type-$auctionId';
      if (getIt.isRegistered<AuctionBidCubit>(instanceName: key)) {
        getIt<AuctionBidCubit>(instanceName: key).updateMaxBid(maxBid);
      }
    },
  ));

  // Auction Bid Repo
  registerLazyIfNeeded<AuctionBidRepo>(() => AuctionBidRepo(getIt<AuctionSocketService>()));

  // Messages
  registerLazyIfNeeded<MessagesRepo>(() => MessagesRepo(getIt<ChatSocketService>()));
  registerFactoryReplacing<MessagesCubit>(() => MessagesCubit(getIt<MessagesRepo>()));
  registerFactoryReplacing<ChatCubit>(() => ChatCubit(getIt<MessagesRepo>()));

  // Offers
  registerLazyIfNeeded<OffersRepo>(() => OffersRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<OfferCubit>(() => OfferCubit(getIt<OffersRepo>()));

  // Service Provider Registration
  registerLazyIfNeeded<ServiceRegistrationRepo>(() => ServiceRegistrationRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ServiceRegistrationCubit>(() => ServiceRegistrationCubit(getIt<ServiceRegistrationRepo>()));

  // Locations (regions/cities)
  registerLazyIfNeeded<LocationRepo>(() => LocationRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<LocationCubit>(() => LocationCubit(getIt<LocationRepo>()));

  // Service Requests
  registerLazyIfNeeded<ServiceRequestRepo>(() => ServiceRequestRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ServiceRequestCubit>(() => ServiceRequestCubit(getIt<ServiceRequestRepo>()));

  // work_with_us
  registerLazyIfNeeded<WorkWithUsRepo>(() => WorkWithUsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<WorkWithUsCubit>(() => WorkWithUsCubit(getIt<WorkWithUsRepo>()));
  registerLazyIfNeeded<PromoterProfileRepo>(() => PromoterProfileRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<PromoterProfileCubit>(() => PromoterProfileCubit(getIt<PromoterProfileRepo>()));
  registerLazyIfNeeded<ExhibitionDetailsRepo>(() => ExhibitionDetailsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ExhibitionDetailsCubit>(() => ExhibitionDetailsCubit(getIt<ExhibitionDetailsRepo>()));
  registerLazyIfNeeded<ExhibitionsRepo>(() => ExhibitionsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ExhibitionsCubit>(() => ExhibitionsCubit(getIt<ExhibitionsRepo>()));
  registerLazyIfNeeded<ExhibitionCreateRepo>(() => ExhibitionCreateRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ExhibitionCreateCubit>(() => ExhibitionCreateCubit(getIt<ExhibitionCreateRepo>()));

  // Commission
  registerLazyIfNeeded<CommissionRepo>(() => CommissionRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<CommissionCubit>(() => CommissionCubit(getIt<CommissionRepo>()));

  // trips
  registerLazyIfNeeded<DynaTripsRepo>(() => DynaTripsRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<DynaTripsListCubit>(() => DynaTripsListCubit(getIt<DynaTripsRepo>()));
  registerFactoryReplacing<DynaMyTripsCubit>(() => DynaMyTripsCubit(getIt<DynaTripsRepo>()));
  registerFactoryReplacing<DynaTripCreateCubit>(() => DynaTripCreateCubit(getIt<DynaTripsRepo>()));

  // ServiceProfile
  registerLazyIfNeeded<ServiceProviderRepo>(() => ServiceProviderRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ProviderCubit>(() => ProviderCubit(getIt<ServiceProviderRepo>()));
  registerLazyIfNeeded<ro.ReceivedOffersRepo>(() => ro.ReceivedOffersRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<roc.ReceivedOffersCubit>(() => roc.ReceivedOffersCubit(getIt<ro.ReceivedOffersRepo>()));
  registerLazyIfNeeded<pr.ProviderRepo>(() => pr.ProviderRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<poc.ProviderOffersCubit>(() => poc.ProviderOffersCubit(getIt<pr.ProviderRepo>()));

  // laborer
  getIt.registerLazySingleton<LaborerTypesRepo>(() => LaborerTypesRepo(getIt<api.ApiService>()));
  getIt.registerFactory<LaborerTypesCubit>(() => LaborerTypesCubit(getIt<LaborerTypesRepo>()));

  getIt.registerLazySingleton<ServiceProvidersRepo>(() => ServiceProvidersRepo(getIt<api.ApiService>()));
  getIt.registerFactory<ServiceProvidersCubit>(() => ServiceProvidersCubit(getIt<ServiceProvidersRepo>()));

  // Car catalog (brands/models)
  registerLazyIfNeeded<CarCatalogRepo>(() => CarCatalogRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<CarCatalogCubit>(() => CarCatalogCubit(getIt<CarCatalogRepo>()));
  registerLazyIfNeeded<CarAuctionRepo>(() => CarAuctionRepo(getIt<api.ApiService>()));
  // 💡 نستخدم FactoryReplacing لتمكين CarAuctionDetailsCubit من أن يكون له مثيل جديد في كل مرة
  registerFactoryReplacing<CarAuctionDetailsCubit>(() => CarAuctionDetailsCubit(getIt<CarAuctionRepo>()));
  registerLazyIfNeeded<ConversationReportRepo>(() => ConversationReportRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<ConversationReportCubit>(() => ConversationReportCubit(getIt<ConversationReportRepo>()));
  // Real Estate Auction Cubit remains the same
  registerLazyIfNeeded<RealEstateAuctionRepo>(() => RealEstateAuctionRepo(getIt<api.ApiService>()));
  registerFactoryReplacing<RealEstateAuctionDetailsCubit>(() => RealEstateAuctionDetailsCubit(getIt<RealEstateAuctionRepo>()));
  getIt.registerLazySingleton<MyAuctionsRepo>(() => MyAuctionsRepo(getIt<api.ApiService>()));
  registerLazyIfNeeded<PaymentConfigRepo>(() => PaymentConfigRepo(getIt<api.ApiService>()));
  getIt.registerLazySingleton<AdsRepo>(() => AdsRepo(getIt<api.ApiService>()));

  // ✅ تم توجيه DynaTripsCubit لاستخدام DynaTripsRepo المدمج
  getIt.registerFactory<DynaTripsCubit>(() => DynaTripsCubit(getIt<DynaTripsRepo>()));

  getIt.registerLazySingleton<ServiceOffersRepo>(() => ServiceOffersRepo(getIt<api.ApiService>()));
  getIt.registerFactory<ServiceOfferCubit>(() => ServiceOfferCubit(getIt<ServiceOffersRepo>()));

}