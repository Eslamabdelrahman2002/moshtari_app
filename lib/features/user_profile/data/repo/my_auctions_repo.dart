import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import '../model/my_auctions_response_model.dart';
import '../model/auction_details_model.dart';

import 'auction_approve_response.dart';

class MyAuctionsRepo {
  final ApiService _apiService;
  MyAuctionsRepo(this._apiService);

  Future<MyAuctionsResponseModel> fetchMyAuctions({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get(
      ApiConstants.myAuctions,
      requireAuth: true,
      queryParameters: {'page': page, 'limit': limit},
    );
    return MyAuctionsResponseModel.fromJson(response);
  }

  Future<AuctionDetailsModel> fetchDetails({
    required int id,
    required String auctionType, // 'real_estate' | 'car'
  }) async {
    final res = await _apiService.get(
      ApiConstants.auctionDetails(id),requireAuth: true,
      queryParameters: {'auction_type': auctionType},
    );
    return AuctionDetailsModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ربط القبول/الرفض
  Future<AuctionApproveResponse> approveAuction({
    required int auctionId,     // مثال: 9
    required String auctionType, // 'car' | 'real_estate'
    required int itemId,        // مثال: 53
    required String action,     // 'accept' | 'reject'
  }) async {
    // مطابق لـ Postman:
    // PUT /api/car-auctions/approve/{auctionId}?auction_type=car
    final map = await _apiService.put(
      ApiConstants.auctionAccept(auctionId, auctionType),
      requireAuth: true,
      data: {
        'auction_type': auctionType,
        'item_id': itemId,
        'action': action,
      },
    );
    return AuctionApproveResponse.fromJson(map);
  }
}