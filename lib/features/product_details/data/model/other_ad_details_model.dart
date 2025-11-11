// lib/features/other_ads/data/models/other_ad_details_model.dart
import 'offer_model.dart';

class OtherAdDetailsModel {
  final int id;
  final String title;
  final String description;
  final String? price;
  final String priceType;
  final String? conditionType;
  final DateTime postedAt;
  final DateTime createdAt;
  final int viewsCount;
  final bool allowMarketingOffers;
  final bool allowComments;
  final List<String> imageUrls;
  final List<String> communicationMethods;
  final List<OfferModel> offers;

  final int? userId; // ✅ الحقل الجديد
  final String username;
  final String email;
  final String userPhone;

  final String cityName;
  final String regionName;
  final String categoryNameAr;
  final String categoryNameEn;

  final String type;
  final String status;

  final List<OtherCommentModel> comments;
  final List<SimilarOtherAdModel> similarAds;

  OtherAdDetailsModel({
    required this.offers,
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceType,
    required this.conditionType,
    required this.postedAt,
    required this.createdAt,
    required this.viewsCount,
    required this.allowMarketingOffers,
    required this.allowComments,
    required this.imageUrls,
    required this.communicationMethods,
    required this.userId, // ✅ إضافته للـ constructor
    required this.username,
    required this.email,
    required this.userPhone,
    required this.cityName,
    required this.regionName,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.type,
    required this.status,
    required this.comments,
    required this.similarAds,
  });

  factory OtherAdDetailsModel.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('Expected Map for OtherAdDetailsModel');
    }
    final root = (json as Map).cast<String, dynamic>();
    final data = root['data'] is Map
        ? (root['data'] as Map).cast<String, dynamic>()
        : root;

    return OtherAdDetailsModel(
      offers: (data['offers'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => OfferModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      id: (data['id'] as num?)?.toInt() ?? 0,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      price: data['price']?.toString(),
      priceType: data['price_type']?.toString() ?? '',
      conditionType: data['condition_type']?.toString(),
      postedAt: DateTime.tryParse(data['posted_at']?.toString() ?? '') ??
          DateTime.now(),
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
      viewsCount: (data['views_count'] as num?)?.toInt() ?? 0,
      allowMarketingOffers: data['allow_marketing_offers'] == true,
      allowComments: data['allow_comments'] == true,
      imageUrls: (data['image_urls'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      communicationMethods: (data['communication_methods'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      userId: (data['user_id'] ?? data['owner_id'] as num?)?.toInt(), // ✅ استخلاص userId
      username: data['username']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      userPhone: data['user_phone']?.toString() ?? '',
      cityName: data['city_name']?.toString() ?? '',
      regionName: data['region_name']?.toString() ?? '',
      categoryNameAr: data['category_name_ar']?.toString() ?? '',
      categoryNameEn: data['category_name_en']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      comments: (data['comments'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => OtherCommentModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      similarAds: (data['similar_ads'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => SimilarOtherAdModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class OtherCommentModel {
  final int id;
  final String text;
  final String userName;
  final String? userPicture;
  final String? offerPrice; // ✅ الحقل الجديد لدعم offer_price

  OtherCommentModel({
    required this.id,
    required this.text,
    required this.userName,
    this.userPicture,
    this.offerPrice, // ✅ إضافته للـ constructor
  });

  factory OtherCommentModel.fromJson(Map<String, dynamic> json) {
    return OtherCommentModel(
      id: (json['comment_id'] as num?)?.toInt() ?? 0,
      text: (json['comment_text'] ?? json['text'] ?? '').toString(),
      userName: (json['user_name'] ?? json['username'] ?? '').toString(),
      userPicture: json['user_picture']?.toString(),
      // ✅ استخراج offer_price كأولوية أولى
      offerPrice: json['offer_price']?.toString() ??
          json['price']?.toString() ??
          json['amount']?.toString(),
    );
  }
}

class SimilarOtherAdModel {
  final int id;
  final String title;
  final String? price;
  final List<String> imageUrls;

  SimilarOtherAdModel({
    required this.id,
    required this.title,
    this.price,
    required this.imageUrls,
  });

  factory SimilarOtherAdModel.fromJson(Map<String, dynamic> json) {
    return SimilarOtherAdModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString(),
      imageUrls: (json['image_urls'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}