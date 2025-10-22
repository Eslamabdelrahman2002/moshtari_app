class AuctionItemModel {
  final int id;
  final String title;
  final String thumbnail;
  final num? currentPrice;
  final String? cityName;
  final String? regionName;
  final String? expiresAt; // ISO

  AuctionItemModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.currentPrice,
    this.cityName,
    this.regionName,
    this.expiresAt,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
  static num? _asNumOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }
  static String _asStr(dynamic v) => v?.toString() ?? '';

  factory AuctionItemModel.fromJson(Map<String, dynamic> j) => AuctionItemModel(
    id: _asInt(j['id']),
    title: _asStr(j['title'] ?? j['name']),
    thumbnail: _asStr(j['thumbnail'] ?? (j['image_urls'] is List && (j['image_urls'] as List).isNotEmpty ? j['image_urls'][0] : '')),
    currentPrice: _asNumOrNull(j['current_price'] ?? j['price'] ?? j['starting_price']),
    cityName: j['city_name_ar']?.toString() ?? j['city']?.toString(),
    regionName: j['region_name_ar']?.toString() ?? j['region']?.toString(),
    expiresAt: j['expires_at']?.toString() ?? j['ends_at']?.toString(),
  );
}

class AuctionDetailsModel {
  final int id;
  final int userId;
  final String type;           // multiple | single
  final String auctionStatus;  // active | ...
  final num? maxBid;           // أعلى مزايدة إن وُجدت
  final List<AuctionItemModel> items;

  AuctionDetailsModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.auctionStatus,
    required this.maxBid,
    required this.items,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
  static String _asStr(dynamic v) => v?.toString() ?? '';
  static num? _asNumOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  factory AuctionDetailsModel.fromJson(Map<String, dynamic> j) {
    final itemsList = (j['items'] as List?) ?? const [];
    return AuctionDetailsModel(
      id: _asInt(j['id']),
      userId: _asInt(j['user_id']),
      type: _asStr(j['type']),
      auctionStatus: _asStr(j['auction_status']),
      maxBid: _asNumOrNull(j['max_bid']),
      items: itemsList.map((e) => AuctionItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}