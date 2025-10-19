// lib/features/car_auctions/data/models/car_auction_details_model.dart
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
    final data = (root['data'] as Map).cast<String, dynamic>();

    return CarAuctionDetailsModel(
      id: (data['id'] as num?)?.toInt() ?? 0,
      type: data['type']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      thumbnail: data['thumbnail']?.toString(),
      isAutoApproval: data['is_auto_approval'] == true,
      startDate: DateTime.tryParse(data['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(data['end_date']?.toString() ?? '') ?? DateTime.now(),
      minBidValue: data['min_bid_value']?.toString() ?? '0',
      status: data['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
      ownerName: data['owner_name']?.toString() ?? '',
      ownerPicture: data['owner_picture']?.toString(),
      maxBid: (data['max_bid'] is num) ? (data['max_bid'] as num).toInt() : int.tryParse(data['max_bid']?.toString() ?? ''),
      activeItem: CarAuctionActiveItem.fromJson((data['active_item'] as Map).cast<String, dynamic>()),
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
    return CarAuctionActiveItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      images: (json['images'] as List? ?? const []).map((e) => e.toString()).toList(),
      pdfFiles: (json['pdf_files'] as List? ?? const []).map((e) => e.toString()).toList(),
      brand: json['brand'] is Map ? Brand.fromJson((json['brand'] as Map).cast<String, dynamic>()) : null,
      model: json['model'] is Map ? CarModel.fromJson((json['model'] as Map).cast<String, dynamic>()) : null,
      color: json['color']?.toString(),
      bodyType: json['body_type']?.toString(),
      year: (json['year'] as num?)?.toInt(),
      kilometers: json['kilometers']?.toString(),
      engineCapacity: json['engine_capacity']?.toString(),
      cylinders: (json['cylinders'] as num?)?.toInt(),
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
    return Brand(
      id: (json['id'] as num?)?.toInt() ?? 0,
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
    return CarModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
    );
  }
}