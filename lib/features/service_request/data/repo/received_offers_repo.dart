import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

import '../model/received_offer_models.dart';

class ReceivedOffersRepo {
  final ApiService _api;
  ReceivedOffersRepo(this._api);

  Future<List<ReceivedOffer>> fetchMyReceivedOffers() async {
    final res = await _api.get(ApiConstants.serviceRequestsMyReceivedOffers);
    final parsed = MyReceivedOffersResponse.fromJson(res as Map<String, dynamic>);
    return parsed.offers;
  }
}