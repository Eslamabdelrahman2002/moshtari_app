// lib/features/car_auctions/data/repo/car_auction_repo.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import '../model/car_auction_details_model.dart';

class CarAuctionRepo {
  final ApiService api;
  CarAuctionRepo(this.api);

  Future<CarAuctionDetailsModel> fetchCarAuction(int id, {int? activeItemId}) async {
    final qp = <String, dynamic>{};
    if (activeItemId != null) {
      // غيّر الاسم حسب المطلوب من API: 'active_item_id' أو 'item_id'
      qp['active_item_id'] = activeItemId;
    }

    final res = await api.getResponse(
      ApiConstants.carAuctionDetails(id),
      relaxStatus: true,
      queryParameters: qp.isEmpty ? null : qp,
    );

    final ct = res.headers.value('content-type') ?? '';
    if (res.statusCode == 200) {
      final body = _asJsonMap(res.data, ct);
      return CarAuctionDetailsModel.fromJson(body);
    }
    if (res.statusCode == 404) {
      throw AppException('المزاد غير موجود');
    }
    final msg = _extractMessage(res.data, ct);
    throw AppException('HTTP ${res.statusCode}: $msg');
  }

  Map<String, dynamic> _asJsonMap(dynamic data, String contentType) {
    if (data is Map<String, dynamic>) return data;
    if (data is String && contentType.contains('application/json')) {
      final d = jsonDecode(data);
      if (d is Map<String, dynamic>) return d;
    }
    throw const FormatException('Unexpected response (not JSON).');
  }

  String _extractMessage(dynamic data, String ct) {
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (data is String) return data;
    return 'حدث خطأ غير متوقع';
  }
  Future<CarAuctionDetailsModel> getAuctionDetails(int id) async {
    final response = await api.get(ApiConstants.carAuctionDetails(id));
    return CarAuctionDetailsModel.fromJson(response['data']);
  }

  // 🟢 NEW: Approve the highest bid for an auction
  Future<Map<String, dynamic>> approveAuction(int id, String auctionType) async {
    // نستخدم GET لأن الـ URL المرفق لا يوحي بوجود Body
    final endpoint = ApiConstants.auctionAccept(id, auctionType);
    final response = await api.get(endpoint);
    return response;
  }

  // 🟢 NEW: Reject the auction result/highest bid
  Future<Map<String, dynamic>> rejectAuction(int id, String auctionType) async {
    final endpoint = ApiConstants.auctionReject(id, auctionType);
    final response = await api.get(endpoint);
    return response;
  }
}