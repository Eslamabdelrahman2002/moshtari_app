import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/api_constants.dart';
import '../model/ad_review_response.dart';

class AdReviewsRepo {
  final ApiService api;
  AdReviewsRepo(this.api);

  Future<AdReviewResponse> postComment({
    required int adId,
    required String comment,
    int? rating,
    Map<String, dynamic>? extraRatings,
  }) async {
    final body = <String, dynamic>{
      'comment': comment,
      if (rating != null) 'rating': rating,
      if (extraRatings != null) ...extraRatings,
    };

    final res = await api.post(ApiConstants.adReviewForAd(adId), body,requireAuth: true);
    return AdReviewResponse.fromJson(res as Map<String, dynamic>);
  }
}