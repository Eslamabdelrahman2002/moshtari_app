import 'my_auctions_model.dart';

class MyAuctionsResponseModel {
  final bool success;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<MyAuctionModel> data;

  MyAuctionsResponseModel({
    required this.success,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  static int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? def;
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    return v.toString().toLowerCase() == 'true' || v.toString() == '1';
  }

  factory MyAuctionsResponseModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];
    return MyAuctionsResponseModel(
      success: _asBool(json['success']),
      page: _asInt(json['page'], 1),
      limit: _asInt(json['limit'], 10),
      total: _asInt(json['total']),
      totalPages: _asInt(json['totalPages']),
      data: list.map((e) => MyAuctionModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}