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
  final int? maxBid;
  final CarAuctionActiveItem activeItem;

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
    required this.activeItem,
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

    final dynamic ai = data['active_item'];
    final Map<String, dynamic> aiMap =
    (ai is Map) ? ai.cast<String, dynamic>() : <String, dynamic>{};

    return CarAuctionDetailsModel(
      id: _toInt(data['id']) ?? 0,
      type: data['type']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      thumbnail: data['thumbnail']?.toString(),
      isAutoApproval: data['is_auto_approval'] == true,
      startDate: _parseDate(data['start_date']),
      endDate: _parseDate(data['end_date']),
      minBidValue: data['min_bid_value']?.toString() ?? '0',
      status: data['status']?.toString() ?? '',
      createdAt: _parseDate(data['created_at']),
      ownerName: data['owner_name']?.toString() ?? '',
      ownerPicture: data['owner_picture']?.toString(),
      maxBid: _toInt(data['max_bid']),
      activeItem: CarAuctionActiveItem.fromJson(aiMap),
    );
  }
}

class CarAuctionActiveItem {
  final int id;
  final String title;
  final String description;
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
    required this.description,
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
      description: json['description']?.toString() ?? '',
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