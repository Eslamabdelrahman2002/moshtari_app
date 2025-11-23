class RealEstateAuctionDetailsModel {
  final int id;
  final String title;
  final String description;
  final String? thumbnail;

  final String startPrice;
  final String? hiddenLimit;
  final bool autoApprove;
  final String bidStep;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final String type;
  final bool isAutoApproval;
  final String minBidValue;

  final String ownerName;
  final String? ownerPicture;
  final num? maxBid;

  // ✅ جديد: نحتفظ بمعرّف الناشر القادم من API (user_id/owner_id)
  final int? ownerId;

  // ✅ خليتها nullable
  final RealEstateAuctionItem? activeItem;

  // ✅ إضافة قائمة بجميع العناصر في المزاد المتعدد
  final List<RealEstateAuctionItem> items;

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
    required this.items, // ✅
    this.ownerId,
  });

  factory RealEstateAuctionDetailsModel.fromJson(dynamic json) {
    final root = (json as Map).cast<String, dynamic>();
    // يدعم الردين: { data: {...} } أو {...} مباشرة
    final Map<String, dynamic> data =
    (root['data'] is Map) ? (root['data'] as Map).cast<String, dynamic>() : root;

    num? _toNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    RealEstateAuctionItem? _parseActiveItem(dynamic v) {
      if (v is Map) {
        return RealEstateAuctionItem.fromJson(v.cast<String, dynamic>());
      }
      return null;
    }

    // دالة مساعدة لتحليل التاريخ
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
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
      // التعامل مع start_time/start_date
      startTime: _parseDate(data['start_time'] ?? data['start_date']),
      // التعامل مع end_time/end_date
      endTime: _parseDate(data['end_time'] ?? data['end_date']),
      createdAt: _parseDate(data['created_at']),
      type: data['type']?.toString() ?? '',
      isAutoApproval: data['is_auto_approval'] == true,
      minBidValue: data['min_bid_value']?.toString() ?? '0',
      ownerName: data['owner_name']?.toString() ?? '',
      ownerPicture: data['owner_picture']?.toString(),
      maxBid: _toNum(data['max_bid']),
      activeItem: _parseActiveItem(data['active_item']),
      // ✅ هنا نقرأ الـ user_id (أو owner_id لو موجود)
      ownerId: _toInt(data['user_id']) ?? _toInt(data['owner_id']),
      // ✅ تحليل قائمة العناصر الجديدة
      items: (data['items'] as List?)
          ?.map((e) => RealEstateAuctionItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList() ??
          const [],
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
    // دالة مساعدة لتحليل التاريخ
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

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
      startDate: _parseDate(json['start_date']?.toString()),
      endDate: _parseDate(json['end_date']?.toString()),
      title: json['title']?.toString() ?? '',
      pdfFiles: (json['pdf_files'] as List? ?? const []).map((e) => e.toString()).toList(),
      images: (json['images'] as List? ?? const []).map((e) => e.toString()).toList(),
      status: json['status']?.toString(),
      cityNameAr: json['city_name_ar']?.toString(),
      cityNameEn: json['city_name_en']?.toString(),
    );
  }
}