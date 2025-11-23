// lib/features/real_estate_auctions/data/repo/real_estate_auction_repo.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import '../model/real_estate_auction_details_model.dart';

class RealEstateAuctionRepo {
  final ApiService api;
  RealEstateAuctionRepo(this.api);

  Future<RealEstateAuctionDetailsModel> fetch(int id, {int? activeItemId}) async {
    final qp = <String, dynamic>{};
    if (activeItemId != null) {
// اختر الاسم حسب API عندك: 'active_item_id' أو 'item_id'
      qp['active_item_id'] = activeItemId;
    }

    final res = await api.getResponse(
      ApiConstants.realEstateAuctionDetails(id),
      relaxStatus: true,
      queryParameters: qp.isEmpty ? null : qp, // ✅ إن كان مدعوم
    );

    final ct = res.headers.value('content-type') ?? '';
    if (res.statusCode == 200) {
      final body = _asJsonMap(res.data, ct);
      return RealEstateAuctionDetailsModel.fromJson(body);
    }
    if (res.statusCode == 404) throw AppException('المزاد غير موجود');
    final msg = _extractMessage(res.data, ct);
    throw AppException('HTTP ${res.statusCode}: $msg');
  }

  Map<String, dynamic> _asJsonMap(dynamic data, String ct) {
    if (data is Map<String, dynamic>) return data;
    if (data is String && ct.contains('application/json')) {
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
}