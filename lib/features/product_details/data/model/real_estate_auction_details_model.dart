class RealEstateAuctionDetailsModel {
  final int id;
  final String title;
  final String description;
  final String? thumbnail;

  final String startPrice;      // e.g. "938"
  final String? hiddenLimit;
  final bool autoApprove;
  final String bidStep;         // e.g. "88"
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final String type;            // single | multiple
  final bool isAutoApproval;
  final String minBidValue;     // e.g. "99"
  final String ownerName;
  final String? ownerPicture;
  final num? maxBid;            // e.g. "522.00" -> 522.0

  // ✅ خليتها nullable
  final RealEstateAuctionItem? activeItem;

  RealEstateAuctionDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.startPrice,
    required this.hiddenLimit,
    required this.autoApprove,
    required this.bidStep,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.type,
    required this.isAutoApproval,
    required this.minBidValue,
    required this.ownerName,
    required this.ownerPicture,
    required this.maxBid,
    required this.activeItem,
  });

  factory RealEstateAuctionDetailsModel.fromJson(dynamic json) {
    final root = (json as Map).cast<String, dynamic>();
    final data = (root['data'] as Map).cast<String, dynamic>();

    num? _toNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    RealEstateAuctionItem? _parseActiveItem(dynamic v) {
      if (v is Map) {
        return RealEstateAuctionItem.fromJson(v.cast<String, dynamic>());
      }
      return null;
    }

    return RealEstateAuctionDetailsModel(
      id: (data['id'] as num?)?.toInt() ?? 0,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      thumbnail: data['thumbnail']?.toString(),
      startPrice: data['start_price']?.toString() ?? '0',
      hiddenLimit: data['hidden_limit']?.toString(),
      autoApprove: data['auto_approve'] == true,
      bidStep: data['bid_step']?.toString() ?? '0',
      startTime: DateTime.tryParse(data['start_time']?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(data['end_time']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
      type: data['type']?.toString() ?? '',
      isAutoApproval: data['is_auto_approval'] == true,
      minBidValue: data['min_bid_value']?.toString() ?? '0',
      ownerName: data['owner_name']?.toString() ?? '',
      ownerPicture: data['owner_picture']?.toString(),
      maxBid: _toNum(data['max_bid']),
      activeItem: _parseActiveItem(data['active_item']), // ✅ آمن على null
    );
  }
}

class RealEstateAuctionItem {
  final int id;
  final int auctionId;
  final String type; // villa, apartment...
  final int? cityId;
  final String? district;
  final String? latitude;
  final String? longitude;
  final String? area;
  final int? numStreets;
  final int? numFloors;
  final int? numRooms;
  final int? numBathrooms;
  final int? streetWidth;
  final String? facade;
  final String? age;
  final bool isFurnished;
  final String? description;

  final String? licenseNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final List<String> pdfFiles;
  final List<String> images;
  final String? status;
  final String? cityNameAr;
  final String? cityNameEn;

  RealEstateAuctionItem({
    required this.id,
    required this.auctionId,
    required this.type,
    this.cityId,
    this.district,
    this.latitude,
    this.longitude,
    this.area,
    this.numStreets,
    this.numFloors,
    this.numRooms,
    this.numBathrooms,
    this.streetWidth,
    this.facade,
    this.age,
    required this.isFurnished,
    this.description,
    this.licenseNumber,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.pdfFiles,
    required this.images,
    this.status,
    this.cityNameAr,
    this.cityNameEn,
  });

  factory RealEstateAuctionItem.fromJson(Map<String, dynamic> json) {
    return RealEstateAuctionItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      auctionId: (json['auction_id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? '',
      cityId: (json['city_id'] as num?)?.toInt(),
      district: json['district']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      area: json['area']?.toString(),
      numStreets: (json['num_streets'] as num?)?.toInt(),
      numFloors: (json['num_floors'] as num?)?.toInt(),
      numRooms: (json['num_rooms'] as num?)?.toInt(),
      numBathrooms: (json['num_bathrooms'] as num?)?.toInt(),
      streetWidth: (json['street_width'] as num?)?.toInt(),
      facade: json['facade']?.toString(),
      age: json['age']?.toString(),
      isFurnished: json['is_furnished'] == true,
      description: json['description']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      title: json['title']?.toString() ?? '',
      pdfFiles: (json['pdf_files'] as List? ?? const []).map((e) => e.toString()).toList(),
      images: (json['images'] as List? ?? const []).map((e) => e.toString()).toList(),
      status: json['status']?.toString(),
      cityNameAr: json['city_name_ar']?.toString(),
      cityNameEn: json['city_name_en']?.toString(),
    );
  }
}