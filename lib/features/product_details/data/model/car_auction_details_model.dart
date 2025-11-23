// lib/features/product_details/ui/screens/models/car_auction_details_model.dart
class CarAuctionDetailsModel {
  final int id;
  final String type;
  final String title;
  final String description;
  final String? thumbnail;
  final bool isAutoApproval;
  final DateTime startDate;
  final DateTime endDate;
  final String minBidValue;
  final String status;
  final DateTime createdAt;
  final String ownerName;
  final String? ownerPicture;
  final num? maxBid;
  final int? ownerId;
  final CarAuctionActiveItem activeItem;
  // ✅ إضافة قائمة بجميع العناصر في المزاد المتعدد (Multiple Auction)
  final List<CarAuctionListItem> items;

  CarAuctionDetailsModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.isAutoApproval,
    required this.startDate,
    required this.endDate,
    required this.minBidValue,
    required this.status,
    required this.createdAt,
    required this.ownerName,
    required this.ownerPicture,
    required this.maxBid,
    required this.ownerId,
    required this.activeItem,
    required this.items, // ✅
  });

  factory CarAuctionDetailsModel.fromJson(dynamic json) {
    if (json is! Map) throw const FormatException('Expected Map');
    final root = (json as Map).cast<String, dynamic>();

    // يدعم الردين: { data: {...} } أو {...} مباشرة
    final Map<String, dynamic> data =
    (root['data'] is Map) ? (root['data'] as Map).cast<String, dynamic>() : root;

    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    int? _toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    num? _toNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    final dynamic ai = data['active_item'];
    final Map<String, dynamic> aiMap = (ai is Map) ? ai.cast<String, dynamic>() : <String, dynamic>{};

    return CarAuctionDetailsModel(
      id: _toInt(data['id']) ?? 0,
      type: data['type']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      thumbnail: data['thumbnail']?.toString(),
      isAutoApproval: data['is_auto_approval'] == true,
      startDate: _parseDate(data['start_date'] ?? data['start_time']),
      endDate: _parseDate(data['end_date'] ?? data['end_time']),
      minBidValue: data['min_bid_value']?.toString() ?? '0',
      status: data['status']?.toString() ?? '',
      createdAt: _parseDate(data['created_at']),
      ownerName: data['owner_name']?.toString() ?? '',
      ownerPicture: data['owner_picture']?.toString(),
      maxBid: _toNum(data['max_bid']),
      ownerId: _toInt(data['user_id']) ?? _toInt(data['owner_id']),
      activeItem: CarAuctionActiveItem.fromJson(aiMap),
      // ✅ تحليل قائمة العناصر الجديدة
      items: (data['items'] as List?)
          ?.map((e) => CarAuctionListItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList() ??
          const [],
    );
  }
}


class CarAuctionActiveItem {
  final int id;
  final String title;
  final String? description; // جعل الوصف nullable بناءً على JSON (وصف Active Item كان null)
  final DateTime startDate;
  final DateTime endDate;
  final List<String> images;
  final List<String> pdfFiles;
  final Brand? brand;
  final CarModel? model;
  final String? color;
  final String? bodyType;
  final int? year;
  final String? kilometers;
  final String? engineCapacity;
  final int? cylinders;
  final String? drivetrain;
  final String? specs;
  final String? startingPrice;
  final String? hiddenMinPrice;

  CarAuctionActiveItem({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.images,
    required this.pdfFiles,
    this.brand,
    this.model,
    this.color,
    this.bodyType,
    this.year,
    this.kilometers,
    this.engineCapacity,
    this.cylinders,
    this.drivetrain,
    this.specs,
    this.startingPrice,
    this.hiddenMinPrice,
  });

  factory CarAuctionActiveItem.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    int? _toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    return CarAuctionActiveItem(
      id: _toInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(), // تم تعديل الوصف ليصبح nullable
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      images: (json['images'] as List? ?? const []).map((e) => e.toString()).toList(),
      pdfFiles: (json['pdf_files'] as List? ?? const []).map((e) => e.toString()).toList(),
      brand: json['brand'] is Map ? Brand.fromJson((json['brand'] as Map).cast<String, dynamic>()) : null,
      model: json['model'] is Map ? CarModel.fromJson((json['model'] as Map).cast<String, dynamic>()) : null,
      color: json['color']?.toString(),
      bodyType: json['body_type']?.toString(),
      year: _toInt(json['year']),
      kilometers: json['kilometers']?.toString(),
      engineCapacity: json['engine_capacity']?.toString(),
      cylinders: _toInt(json['cylinders']),
      drivetrain: json['drivetrain']?.toString(),
      specs: json['specs']?.toString(),
      startingPrice: json['starting_price']?.toString(),
      hiddenMinPrice: json['hidden_min_price']?.toString(),
    );
  }
}

// ✅ NEW CLASS: يمثل عنصراً واحداً من قائمة العناصر (items) في المزاد المتعدد.
class CarAuctionListItem {
  final int id;
  final int auctionId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> images;
  final List<String> pdfFiles;
  final String? color;
  final String? bodyType;
  final int? year;
  final String? kilometers;
  final String? engineCapacity;
  final int? cylinders;
  final String? drivetrain;
  final String? specs;
  final String? startingPrice;
  final String? hiddenMinPrice;
  final int? brandId;
  final int? modelId;
  final String? brandName;
  final String? modelNameAr;
  final String? modelNameEn;
  final String? status;

  CarAuctionListItem({
    required this.id,
    required this.auctionId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.images,
    required this.pdfFiles,
    this.color,
    this.bodyType,
    this.year,
    this.kilometers,
    this.engineCapacity,
    this.cylinders,
    this.drivetrain,
    this.specs,
    this.startingPrice,
    this.hiddenMinPrice,
    this.brandId,
    this.modelId,
    this.brandName,
    this.modelNameAr,
    this.modelNameEn,
    this.status,
  });

  factory CarAuctionListItem.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    int? _toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    return CarAuctionListItem(
      id: _toInt(json['id']) ?? 0,
      auctionId: _toInt(json['auction_id']) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      images: (json['images'] as List? ?? const []).map((e) => e.toString()).toList(),
      pdfFiles: (json['pdf_files'] as List? ?? const []).map((e) => e.toString()).toList(),
      color: json['color']?.toString(),
      bodyType: json['body_type']?.toString(),
      year: _toInt(json['year']),
      kilometers: json['kilometers']?.toString(),
      engineCapacity: json['engine_capacity']?.toString(),
      cylinders: _toInt(json['cylinders']),
      drivetrain: json['drivetrain']?.toString(),
      specs: json['specs']?.toString(),
      startingPrice: json['starting_price']?.toString(),
      hiddenMinPrice: json['hidden_min_price']?.toString(),
      // حقول الماركة والموديل التي تأتي بشكل مفلطح (flat) في قائمة العناصر
      brandId: _toInt(json['brand_id']),
      modelId: _toInt(json['model_id']),
      brandName: json['brand_name']?.toString(),
      modelNameAr: json['model_name_ar']?.toString(),
      modelNameEn: json['model_name_en']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class Brand {
  final int id;
  final String name;
  Brand({required this.id, required this.name});
  factory Brand.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    return Brand(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class CarModel {
  final int id;
  final String nameAr;
  final String nameEn;
  CarModel({required this.id, required this.nameAr, required this.nameEn});
  factory CarModel.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    return CarModel(
      id: _toInt(json['id']) ?? 0,
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
    );
  }
}