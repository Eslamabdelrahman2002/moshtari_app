// core/api/api_constants.dart
class ApiConstants {
  // REST base
  static const String baseUrl = 'http://87.237.225.78:8888/api/';

  // WebSocket host (IP:PORT)
  static const String wsHost = '87.237.225.78:8888';

  // Socket URL builder: ws في التطوير، و wss في الإنتاج مع شهادة SSL صحيحة
  static String chatSocketUrl(String token, {bool secure = false}) {
    final scheme = secure ? 'wss' : 'ws';
    return '$scheme://$wsHost?token=$token';
  }

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String verifyRegistration = 'auth/verify-registration';
  static const String forgetPassword = 'auth/forget-password';
  static const String resetPassword = 'auth/reset-password';
  static const String verifyResetPassword = 'auth/verify-otp';

  // Home
  static const String home = 'users/home';

  // User
  static const String userProfile = 'users/profile';
  static const String myAds = 'my-ads';
  static const String favorites = 'favorites';

  // Messages (REST fallback)
  static const String conversations = 'messages/conversations';
  static const String sendMessage = 'messages';
  static String conversationMessages(String conversationId) =>
      'messages/conversation/$conversationId';

  // Auctions
  static const String carAuctions = 'car-auctions';
  static String carAuctionDetails(int id) => '$carAuctions/$id';
  static const String carAuctionsStart = 'car-auctions/start';

  static const String realEstateAuctions = 'real-estate-auctions';
  static String realEstateAuctionDetails(int id) => '$realEstateAuctions/$id';
  static const String realEstateAuctionsStart = 'real-estate-auctions/start';

  // Cars
  static const String carAds = 'car-ads';
  static String carAdDetails(int id) => '$carAds/$id';
  static String carAdDetailsByQuery(int id) => '$carAds?id=$id';
  // ملاحظة: احتفظنا بنفس القيمة لو مشروعك يعتمد عليها
  static const String carAdsCreate = 'car-ads/car-ads';
  static const String carImagesKey = 'image_urls';
  static const String carTechnicalReportKey = 'technical_report';

  // Car parts
  static const String carPartAds = 'car-part-ads';
  // كان سبب التكرار /car-part-ads/car-part-ads
  @Deprecated('Use carPartAds only')
  static const String carPartAdsResource = 'car-part-ads/car-part-ads';
  static String carPartAdDetails(int id) => '$carPartAds/$id';
  @Deprecated('Use carPartAdDetails')
  static String carPartAdDetailsV1(int id) => carPartAdDetails(id);
  @Deprecated('Use carPartAdDetails')
  static String carPartAdDetailsV2(int id) => 'car-part-ads/car-part-ads/$id';
  // إنشاء قطع الغيار: استخدم المسار الصحيح بدون resource مكرر
  static const String carPartAdsCreate = 'car-part-ads';
  static const String carPartImagesKey = 'image_urls';

  // Real estate ads
  static const String realEstateAds = 'real-estate-ads';
  static String realEstateAdDetails(int id) => '$realEstateAds/$id';
  static const String realEstateCreateAd = 'real-estate-ads';
  static const String realEstateImagesKey = 'image_urls';

  // Other ads
  static const String otherAds = 'other-ads';
  static String otherAdDetails(int id) => '$otherAds/$id';
  static const String otherAdImagesKey = 'image_urls';

  // Reviews
  static const String adReviews = 'ad-reviews';
  static String adReviewForAd(int adId) => '$adReviews/$adId/review';

  // Marketing
  static const String marketingRequests = 'marketing-requests';
  // offers
  static const String submitOffer = 'offers/offers';
  static String offerById(int id) => 'offers/offers/$id';

  // Service Provider Registration
  static const String registerServiceProvider = 'service-provider/register';

  // Locations
  static const String regions = 'regions';
  static const String cities = 'cities';
  static String citiesByRegion(int regionId) => '$cities?region_id=$regionId';

  // Service Requests
  static const String serviceRequests = 'service-requests';
  static const String serviceRequestsCreate = 'service-requests/create';

  // work_with_us
  static const String promoterApplicationsApply = 'promoter-applications/apply';
  static const String promoterApplicationsProfile = 'promoter-applications/profile';

  static const String exhibitions = 'exhibitions';
  static String exhibitionDetailsById(int id) => '$exhibitions/$id';

  // trips
  static const String dynaTripsAdd = 'dyna-trips/add';
  static const String dynaTrips = 'dyna-trips';
  static const String dynaMyTrips = 'dyna-trips/my_trips';

  // commission
  static const String commission = 'commission';

  // serviceProviderProfile
  static String serviceProviderProfile(int id) => 'service-provider/providers/$id';
  static const String serviceProviderRequests = 'service-provider/service-requests';
  static String serviceProviderUpdateRequestStatus(int requestId) =>
      'service-provider/update-request-status/$requestId';

  // Service requests - my received offers
  static const String serviceRequestsMyReceivedOffers = 'service-requests/my-received-offers';
  static String serviceOfferAccept(int offerId) => 'service-offers/offers/$offerId/accept';

  // laborer
  static const String laborerTypes = 'laborer-types';
  static const String serviceProviders = 'service-provider/labours';

  // car
  static const String carTypes = 'car-types';
  static String carTypeModels(int typeId) => 'car-types/$typeId/models';
}