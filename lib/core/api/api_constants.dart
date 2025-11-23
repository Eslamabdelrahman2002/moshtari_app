// lib/core/api/api_constants.dart

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
  static String serviceOfferReject(int offerId) => 'service-offers/offers/$offerId/reject';
  static const String serviceRequestsMyRequests = 'service-requests/my-requests';
  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String verifyRegistration = 'auth/verify-registration';
  static const String forgetPassword = 'auth/forget-password';
  static const String resetPassword = 'auth/reset-password';
  static const String verifyResetPassword = 'auth/verify-otp';
  static const String usersSearch = 'users/search';
  // Home
  static const String home = 'users/home';
// Notifications
  static String getNotifications(int userId) => 'notifications/$userId';
  static String markNotificationAsRead(int notificationId) => 'notifications/read/$notificationId';
  static const String readAllNotifications = 'notifications/read-all';
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
  static String auctionAccept(int id, String type) => 'car-auctions/approve/$id?auction_type=$type';
  static String auctionReject(int id, String type) => 'car-auctions/reject/$id?auction_type=$type';
  static const String myAuctions = 'car-auctions/my-auctions';
  static String auctionDetails(int id) => 'car-auctions/auction-details/$id';
  // Cars
  static const String carAds = 'car-ads';
  static String carAdDetails(int id) => '$carAds/$id';
  static String carAdDetailsByQuery(int id) => '$carAds?id=$id';
  static const String carAdsCreate = 'car-ads/car-ads';
  static String updateCarAd(int id) => '$carAds/$id';
  static const String carImagesKey = 'image_urls';
  static const String carTechnicalReportKey = 'technical_report';

  // Car parts
  static const String carPartAds = 'car-part-ads';

  static  String carPartAdsUpdate(int id)=>"$carPartAds/$carPartAds/$id";
  static String carPartAdDetails(int id) => '$carPartAds/$carPartAds/$id';
  static const String carPartAdsCreate = 'car-part-ads/car-part-ads'; // تم تصحيح المسار
  static const String carPartImagesKey = 'image_urls';



  // Real estate ads
  static const String realEstateAds = 'real-estate-ads';
  static String realEstateAdDetails(int id) => '$realEstateAds/$id';
  static const String realEstateCreateAd = 'real-estate-ads';
  static const String realEstateImagesKey = 'image_urls';

  // Other ads
  static const String otherAds = 'other-ads';
  static String otherAdDetails(int id) => '$otherAds/$id';
  static String updateOtherAd(int id) => '$otherAds/$id';
  static const String otherAdImagesKey = 'image_urls';
  static String getRealEstateAdDetails(int id) => '$realEstateAds/$id';
  // Reviews
  static const String adReviews = 'ad-reviews';
  static String adReviewForAd(int adId) => '$adReviews/$adId/review';
  // مفاتيح الحقول
  static const String realEstateImageUrlsKey = 'image_urls'; // للتحديث فقط
  // لو عندك خدمات
  static const String servicesKey = 'services';
  // ✅ New: Endpoint لتعديل إعلان عقار (PUT/PATCH)
  static String updateRealEstateAd(int id) => '$realEstateAds/$id';
  // Marketing
  static const String marketingRequests = 'marketing-requests';
  //offers
  static const String submitOffer = 'offers/offers';
  static String offerById(int id) => 'offers/offers/$id';
  // Service Provider Registration
  static const String registerServiceProvider = 'service-provider/register';
  // Locations
  static const String regions = 'regions';
  static const String cities = 'cities';
  static String citiesByRegion(int regionId) => '$cities?region_id=$regionId';

  // Real estate requests (View/Details)
  static const String realEstateListings = 'real-estate-requests/real-estate/listings';
  static String realEstateRequestDetails(int id) => 'real-estate-requests/real-estate-requests/$id';
  // Real estate requests (Create)
  static const String realEstateRequestsCreate = 'real-estate-requests/real-estate-requests'; // ✅ مسار جديد لإنشاء الطلبات

  // Service Requests
  static const String serviceRequests = 'service-requests';
  static const String serviceRequestsCreate = 'service-requests/create';
  //work_with_us
  static const String promoterApplicationsApply = 'promoter-applications/apply';
  static const String promoterApplicationsProfile = 'promoter-applications/profile';
  static const String exhibitions = 'exhibitions';
  static String exhibitionDetailsById(int id) => '$exhibitions/$id';
  //tribs
  static const String dynaTripsAdd = 'dyna-trips/add';
  static const String dynaTrips = 'dyna-trips';
  static const String dynaMyTrips = 'dyna-trips/my_trips';
  //commission
  static const String commission = 'commission';
  //serviceProviderProfile
  static String serviceProviderProfile(int id) => 'service-provider/providers/$id';
  static const String serviceProviderRequests = 'service-provider/service-requests';
  static String serviceProviderUpdateRequestStatus(int requestId) =>
      'service-provider/update-request-status/$requestId';
  // Service requests - my received offers
  static const String serviceRequestsMyReceivedOffers = 'service-requests/my-received-offers';
  static String serviceOfferAccept(int offerId) => 'service-offers/offers/$offerId/accept';
  //laborer
  static const String laborerTypes = 'laborer-types';
  static const String serviceProviders = 'service-provider/labours';
  //car
  static const String carTypes = 'car-types';
  static String carTypeModels(int typeId) => 'car-types/$typeId/models';
  static String get myReceivedOffers => 'service-requests/my-received-offers';
  static const String deleteAccount = 'users/delete-account';
  static String conversationReport(int conversationId) => 'conversation-reports/$conversationId/report';
  // Payments (MyFatoorah)
  // مثال: يرجّع { "base_url": "...", "token": "...", "currency": "SAR" }
  static const String myFatoorahConfig = 'payments/myfatoorah/config';
  static String deleteCarAd(int id) => 'car-ads/$id';
  static String deleteRealEstateAd(int id) => 'real-estate-ads/$id';
  static String deleteCarPartAd(int id) => 'car-part-ads/car-part-ads/$id';
  static String deleteOtherAd(int id) => 'other-ads/$id';
  static const String logout = 'users/log-out';
  static String userReviews(int userId) => 'ad-reviews/user/$userId';
  static String get carAdsUser => 'car-ads/user'; // لـ /user/{id}
  static String get carAuctionsUser => 'car-auctions/user'; // لـ /user/{id}
  // adType: 'car' | 'real_estate' | 'car_part' | 'other'
  static String deleteAdPath({required String adType, required int id}) {
    switch (adType) {
      case 'car':
        return deleteCarAd(id);
      case 'real_estate':
        return deleteRealEstateAd(id);
      case 'car_part':
        return deleteCarPartAd(id);
      case 'other':
        return deleteOtherAd(id);
      default:
        throw ArgumentError('Unsupported adType: $adType');
    }
  }
  static String dynaTripById(int id) => 'dyna-trips/$id';
  static String getPublisherProfile(int userId) => 'users/$userId';
  static String getPublisherAds(int userId) => '$carAds/my-ads/$userId';
  static String getPublisherAuctions(int userId) => '$carAuctions/my-auctions/$userId';
  static const String dynaTripsAvailable = 'dyna-trips/available';
  static const String serviceOffers = 'service-offers/offers';
  static const String resendOtp = 'auth/resend-otp';
  static String bumpAdPath({required String adType, required int id}) {
    switch (adType) {
      case 'car':
        return '$carAds/$id'; // car-ads/{id}
      case 'real_estate':
        return '$realEstateAds/$id'; // real-estate-ads/{id}
      case 'car_part':
      // car-part-ads/car-part-ads/{id}
        return '$carPartAds/$carPartAds/$id';
      case 'other':
        return '$otherAds/$id'; // other-ads/{id}
      default:
        throw ArgumentError('Unsupported adType: $adType');
    }
  }
}