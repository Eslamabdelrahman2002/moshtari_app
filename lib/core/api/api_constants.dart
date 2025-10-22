
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
    static String auctionAccept(int id, String type) => 'car-auctions/approve/$id?auction_type=$type';
    static String auctionReject(int id, String type) => 'car-auctions/reject/$id?auction_type=$type';
    static const String myAuctions = 'car-auctions/my-auctions';
    static String auctionDetails(int id) => 'car-auctions/auction-details/$id';
    // Cars
    static const String carAds = 'car-ads';
    static String carAdDetails(int id) => '$carAds/$id';
    static String carAdDetailsByQuery(int id) => '$carAds?id=$id';
    static const String carAdsCreate = 'car-ads/car-ads';
    static const String carImagesKey = 'image_urls';
    static const String carTechnicalReportKey = 'technical_report';

    // Car parts
    static const String carPartAds = 'car-part-ads';
    static String carPartAdDetails(int id) => '$carPartAds/$carPartAds/$id';
    static const String carPartAdsCreate = 'car-part-ads'; // تم تصحيح المسار
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
    //offers
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
    static const String dynaTripsAvailable = 'dyna-trips/available';
    static const String serviceOffers = 'service-offers/offers';
  }