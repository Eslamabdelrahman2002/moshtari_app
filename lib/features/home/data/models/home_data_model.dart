import 'package:flutter/foundation.dart';
import '../../../favorites/data/model/favorites_model.dart';

// Banner
class BannerModel {
  final int id;
  final String imageUrl;
  BannerModel({required this.id, required this.imageUrl});
  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      BannerModel(id: json['id'] ?? 0, imageUrl: json['image_url'] ?? '');
}

// Category
class CategoryModel {
  final int id;
  final String name;
  final String? iconUrl;
  CategoryModel({required this.id, required this.name, this.iconUrl});
  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] ?? 0,
    name: json['name_ar'] ?? json['name'] ?? '',
    iconUrl: json['icon_url'],
  );
}

// Auctions
class AuctionsModel {
  final int id;
  final String title;
  final String? thumbnail;
  final String? status;
  final String username;
  final String createdAt;
  final String? auctionType; // car | real_estate | car_parts | other?
  final String? type;        // single | multiple

  AuctionsModel({
    required this.id,
    required this.title,
    this.thumbnail,
    this.status,
    required this.username,
    required this.createdAt,
    this.auctionType,
    this.type,
  });

  factory AuctionsModel.fromJson(Map<String, dynamic> json) => AuctionsModel(
    id: json['id'] ?? 0,
    title: json['title'] ?? 'No Title',
    thumbnail: json['thumbnail'],
    status: json['status'],
    username: json['username'] ?? json['owner_name'] ?? 'Unknown User',
    createdAt: json['created_at'] ?? DateTime(1970).toIso8601String(),
    auctionType: json['auction_type'],
    type: json['type'],
  );
}

class HomeAdModel {
  final int id;
  final int? categoryId;
  final String title;
  final String? price;
  final List<String> imageUrls;
  final String createdAt;
  final String? condition;
  final String location;
  final String username;
  final String? phoneNumber;
  final String? auctionDisplayType;
  final int? auctionId;

  // car_ads | real_estate_ads | car_parts_ads | other_ads | auction
  final String? sourceType;

  HomeAdModel({
    required this.id,
    this.categoryId,
    required this.title,
    this.price,
    required this.imageUrls,
    required this.createdAt,
    this.condition,
    required this.location,
    required this.username,
    this.phoneNumber,
    this.auctionDisplayType,
    this.auctionId,
    this.sourceType,
  });

  // NEW: ميثود مريحة للفرز لو حبيت تستخدمها
  DateTime get createdAtDate => DateTime.tryParse(createdAt) ?? DateTime(1970);

  // NEW: الآن تقدر تستخدم ad.isAuction في أي مكان
  bool get isAuction {
    final st = (sourceType ?? '').toLowerCase();
    return auctionDisplayType != null || st.contains('auction') || auctionId != null || (price == 'مزاد');
  }

  HomeAdModel copyWith({
    int? id,
    int? categoryId,
    String? title,
    String? price,
    List<String>? imageUrls,
    String? createdAt,
    String? condition,
    String? location,
    String? username,
    String? phoneNumber,
    String? auctionDisplayType,
    int? auctionId,
    String? sourceType,
  }) {
    return HomeAdModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      auctionDisplayType: auctionDisplayType ?? this.auctionDisplayType,
      auctionId: auctionId ?? this.auctionId,
      sourceType: sourceType ?? this.sourceType,
    );
  }

  factory HomeAdModel.fromJson(Map<String, dynamic> json) {
    String loc = 'Unknown Location';
    if (json['city'] is Map && (json['city'] as Map)['name'] != null) {
      loc = (json['city'] as Map)['name'].toString();
    } else if (json['region'] is Map && (json['region'] as Map)['name'] != null) {
      loc = (json['region'] as Map)['name'].toString();
    } else if (json['name_ar'] != null) {
      loc = (json['name_ar']).toString();
    } else if (json['location'] != null) {
      loc = (json['location']).toString();
    }

    final created = (json['created_at'] ?? DateTime(1970).toIso8601String()).toString();

    return HomeAdModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'],
      title: json['title'] ?? 'No Title',
      price: json['price']?.toString(),
      imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : [],
      createdAt: created,
      condition: json['condition'] ?? json['purpose'],
      location: loc,
      username: json['username'] ?? 'Unknown User',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString(),
      auctionDisplayType: null,
      auctionId: null,
      sourceType: null,
    );
  }

  // من سكشن معيّن
  factory HomeAdModel.fromSection(Map<String, dynamic> json, String sectionKey) {
    int cat = 4;
    switch (sectionKey) {
      case 'car_ads':        cat = 1; break;
      case 'real_estate_ads':cat = 2; break;
      case 'car_parts_ads':
      case 'car_part_ads':   cat = 3; break;
      case 'other_ads':
      default:               cat = 4;
    }

    final base = HomeAdModel.fromJson(json);
    return base.copyWith(
      categoryId: cat,
      sourceType: sectionKey,
    );
  }

  factory HomeAdModel.fromAuction(AuctionsModel auction) {
    int? categoryId;
    switch (auction.auctionType) {
      case 'car':         categoryId = 1; break;
      case 'real_estate': categoryId = 2; break;
      case 'car_parts':   categoryId = 3; break;
      default:            categoryId = 4;
    }

    return HomeAdModel(
      id: auction.id,
      auctionId: auction.id,
      categoryId: categoryId,
      title: auction.title,
      price: 'مزاد',
      imageUrls: auction.thumbnail != null ? [auction.thumbnail!] : [],
      createdAt: auction.createdAt,
      condition: auction.status,
      location: 'مزاد عبر الإنترنت',
      username: auction.username,
      phoneNumber: null,
      auctionDisplayType: auction.type,
      sourceType: 'auction', // مفيد كـ fallback
    );
  }

  // من المفضلة
  factory HomeAdModel.fromFavorite(FavoriteItemModel favorite) {
    final d = favorite.details;
    final isAuctionFav = favorite.favoriteType == 'auction';

    final images = (d.imageUrls?.isNotEmpty ?? false)
        ? d.imageUrls!
        : (d.thumbnail != null && d.thumbnail!.isNotEmpty ? [d.thumbnail!] : <String>[]);

    final title = (d.title?.trim().isNotEmpty ?? false) ? d.title!.trim() : 'No Title';

    return HomeAdModel(
      id: favorite.favoriteId,
      auctionId: isAuctionFav ? favorite.favoriteId : null,
      title: title,
      price: isAuctionFav ? 'مزاد' : d.price,
      imageUrls: images,
      createdAt: d.createdAt ?? DateTime(1970).toIso8601String(),
      location: d.location ?? 'Unknown Location',
      username: d.username ?? 'Unknown User',
      phoneNumber: d.phoneNumber,
      auctionDisplayType: isAuctionFav ? 'single' : null,
      categoryId: null,
      condition: null,
      sourceType: isAuctionFav ? 'auction' : null,
    );
  }
}

// HomeDataModel
class HomeDataModel {
  final List<HomeAdModel> carAds;
  final List<HomeAdModel> realEstateAds;
  final List<HomeAdModel> carPartsAds;
  final List<HomeAdModel> otherAds;
  final List<AuctionsModel> auctions;
  final List<CategoryModel> categories;
  final List<BannerModel> banners;

  HomeDataModel({
    required this.carAds,
    required this.realEstateAds,
    required this.carPartsAds,
    required this.otherAds,
    required this.auctions,
    required this.categories,
    required this.banners,
  });

  // Helper
  List<HomeAdModel> adsByCategory(int categoryId) {
    switch (categoryId) {
      case 1: return carAds;
      case 2: return realEstateAds;
      case 3: return carPartsAds;
      case 4: return otherAds;
      default:
        return [...carAds, ...realEstateAds, ...carPartsAds, ...otherAds];
    }
  }

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(List src, T Function(Map<String, dynamic>) fromJson) =>
        src.map((item) => fromJson(Map<String, dynamic>.from(item))).toList();

    List<HomeAdModel> tag(String key) {
      final list = (json[key] as List? ?? []);
      return list.map<HomeAdModel>((raw) {
        final item = Map<String, dynamic>.from(raw as Map);
        return HomeAdModel.fromSection(item, key);
      }).toList();
    }

    final carPartKey = json.containsKey('car_parts_ads') ? 'car_parts_ads' : 'car_part_ads';

    final carAds        = tag('car_ads');
    final realEstateAds = tag('real_estate_ads');
    final carPartsAds   = tag(carPartKey);
    final otherAds      = tag('other_ads');

    final auctions = parseList<AuctionsModel>((json['auctions'] as List? ?? []), (item) => AuctionsModel.fromJson(item));
    final categories = parseList<CategoryModel>((json['categories'] as List? ?? []), (item) => CategoryModel.fromJson(item));
    final banners = parseList<BannerModel>((json['banners'] as List? ?? []), (item) => BannerModel.fromJson(item));

    return HomeDataModel(
      carAds: carAds,
      realEstateAds: realEstateAds,
      carPartsAds: carPartsAds,
      otherAds: otherAds,
      auctions: auctions,
      categories: categories,
      banners: banners,
    );
  }
}