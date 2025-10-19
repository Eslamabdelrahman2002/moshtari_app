// lib/features/favorites/data/model/favorites_model.dart

// This class represents the nested "details" object in your API response
class FavoriteDetailsModel {
  final String? title;
  final String? description;
  final String? price;
  final String? thumbnail;
  final List<String>? imageUrls;
  final String? createdAt;
  final String? location;
  final String? username;
  final String? phoneNumber; // <<< الخطوة 1: تمت إضافة الخاصية هنا

  FavoriteDetailsModel({
    this.title,
    this.description,
    this.price,
    this.thumbnail,
    this.imageUrls,
    this.createdAt,
    this.location,
    this.username,
    this.phoneNumber, // <<< الخطوة 2: تمت إضافته إلى الـ constructor
  });

  factory FavoriteDetailsModel.fromJson(Map<String, dynamic> json) {
    // Get images from either 'thumbnail' or 'image_urls'
    List<String> images = [];
    if (json['thumbnail'] != null) {
      images.add(json['thumbnail']);
    }
    if (json['image_urls'] is List) {
      images.addAll(List<String>.from(json['image_urls']));
    }

    return FavoriteDetailsModel(
      title: json['title'],
      description: json['description'],
      price: json['price']?.toString() ?? json['min_bid_value']?.toString(),
      thumbnail: json['thumbnail'],
      imageUrls: images,
      createdAt: json['created_at'],
      location: json['name_ar'],
      username: json['username'],
      // <<< الخطوة 3: تم سحب رقم الهاتف من الـ JSON
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString(),
    );
  }
}

// This is the main model for each item in the favorites list
class FavoriteItemModel {
  final int id; // The ID of the favorite record itself (e.g., 34)
  final String favoriteType;
  final int favoriteId; // The ID of the ad or auction (e.g., 3)
  final FavoriteDetailsModel details;

  FavoriteItemModel({
    required this.id,
    required this.favoriteType,
    required this.favoriteId,
    required this.details,
  });

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      id: json['id'] ?? 0,
      favoriteType: json['favorite_type'] ?? '',
      favoriteId: json['favorite_id'] ?? 0,
      details: FavoriteDetailsModel.fromJson(json['details'] ?? {}),
    );
  }
}