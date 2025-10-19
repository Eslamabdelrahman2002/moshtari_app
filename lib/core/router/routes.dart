class Routes {
  // Core
  static const String splashScreen = '/';
  static const String onboardingScreen = '/onboardingScreen';
  static const String bottomNavigationBar = '/bottomNavigationBar';

  // Auth
  static const String loginScreen = '/loginScreen';
  static const String registerScreen = '/registerScreen';
  static const String otpScreen = '/otpScreen';
  static const String forgetPasswordScreen = '/forgetPasswordScreen';
  static const String resetPasswordScreen = '/resetPasswordScreen';
  static const String completeProfileScreen = '/completeProfileScreen';

  // Home
  static const String homeScreen = '/homeScreen';
  static const String reelsScreen = '/reelsScreen';

  // User/Profile
  static const String userProfileScreen = '/userProfileScreen';
  static const String updateProfileScreen = '/updateProfileScreen';

  // Menu/Settings/Wallet
  static const String menuScreen = '/menuScreen';
  static const String languagesScreen = '/languagesScreen';
  static const String earningsScreen = '/earningsScreen';
  static const String walletScreen = '/walletScreen';
  static const String favoritesScreen = '/favoritesScreen';
  static const String technicalSupportScreen = '/technicalSupportScreen';
  static const String commissionCalculatorScreen = '/commissionCalculatorScreen'; // موجود

  // Work with us
  static const String workWithUsIntroScreen = '/workWithUsIntroScreen';
  static const String workWithUsFormScreen = '/workWithUsFormScreen';

  // Details (products)
  static const String productDetails = '/productDetails';
  static const String fullViewProductDetailsScreen = '/fullViewProductDetailsScreen';
  static const String storyViewScreen = '/storyViewScreen';
  static const String carDetailsScreen = '/carDetailsScreen';
  static const String carPartDetailsScreen = '/carPartDetailsScreen';
  static const String otherAdDetailsScreen = '/otherAdDetailsScreen';

  // Real estate
  static const String realEstateScreen = '/realEstatesScreen';
  static const String realEstateDetailsScreen = '/realEstateDetailsScreen';
  static const String realEstateApplicationsDetailsScreen = '/realEstateApplicationsDetailsScreen';

  // Auctions
  static const String carAuctionDetailsScreen = '/carAuctionDetailsScreen';
  static const String realEstateAuctionDetailsScreen = '/realEstateAuctionDetailsScreen';
  static const String createCarAuctionScreen = '/createCarAuctionScreen';
  static const String createRealEstateAuctionScreen = '/createRealEstateAuctionScreen';
  static const String publishEntryScreen = '/publishEntryScreen';
  static const String auctionCategoryPickerScreen = '/auctionCategoryPickerScreen';

  // Create flows
  static const String createAdScreen = '/createAdScreen';
  static const String createCarAdFlow = '/createCarAdFlow';
  static const String createRealEstateAdFlow = '/createRealEstateAdFlow';

  // Car parts create flow
  static const String createCarPartAdScreen = '/createCarPartAdScreen';
  static const String createCarPartAdStep1 = '/createCarPartAdStep1';
  static const String createCarPartAdStep2 = '/createCarPartAdStep2';

  // Other create flow
  static const String createOtherAdStep1 = '/createOtherAdStep1';
  static const String createOtherAdStep2 = '/createOtherAdStep2';

  // Chat/Notifications/Workers
  static const String chatScreen = '/chatScreen';
  static const String notificationsScreen = '/notificationsScreen'; // اسم صحيح
  static const String workerDetailsScreen = '/workerDetailsScreen'; // مضاف

  // Custom Flow Screens (Adding new routes for the main step widgets)
  static const String completeProfileSteps = '/completeProfileSteps'; // لـ اجير
  static const String transportServiceSteps = '/transportServiceSteps'; // لـ دينات
  static const String deliveryServiceSteps = '/deliveryServiceSteps'; // لـ سطحة
  static const String tankerServiceSteps = '/tankerServiceSteps'; // لـ صهريج
  //trips
  static const String createDynaTripScreen = '/createDynaTripScreen';
  static const String dynaMyTripsScreen = '/dynaMyTripsScreen';
  static const String dynaTripsScreen = '/dynaTripsScreen';
  static const String dynaTripsManagerScreen = '/dynaTripsManagerScreen';
  //service_profile
  static const String serviceProviderDashboard = '/serviceProviderDashboard';
  static const String serviceProviderDashboard1 = '/serviceProviderDashboard';
  static const String serviceRequestsScreen = '/serviceRequestsScreen';
  static const String myReceivedOffersScreen = '/myReceivedOffersScreen';
}