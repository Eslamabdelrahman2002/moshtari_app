
import 'offer_model.dart';

class CarPartDetailsModel {
  final int id;
  final String title;
  final String description;
  final String price;
  final String phoneNumber;
  final List<String> communicationMethods;
  final List<String> imageUrls;
  final String city;
  final String region;
  final DateTime createdAt;
  final CarPartDetail carPartDetail;
  final User user;
  final List<Comment> comments;
  final List<SimilarAd> similarAds;
  final List<OfferModel> offers;

  CarPartDetailsModel({
    required this.offers,
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.phoneNumber,
    required this.communicationMethods,
    required this.imageUrls,
    required this.city,
    required this.region,
    required this.createdAt,
    required this.carPartDetail,
    required this.user,
    required this.comments,
    required this.similarAds,
  });

  factory CarPartDetailsModel.fromJson(Map<String, dynamic> json) {
    return CarPartDetailsModel(
      id: json['id'],
      offers: (json['offers'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => OfferModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      communicationMethods:
      List<String>.from(json['communication_methods'] ?? []),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      city: json['city']?['name'] ?? '',
      region: json['region']?['name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      carPartDetail: CarPartDetail.fromJson(json['car_part_detail']),
      user: User.fromJson(json['user']),
      comments:
      (json['comments'] as List).map((e) => Comment.fromJson(e)).toList(),
      similarAds: (json['similar_ads'] as List)
          .map((e) => SimilarAd.fromJson(e))
          .toList(),
    );
  }
}

class CarPartDetail {
  final String partName;
  final String condition;
  final String brandName;
  final List<String> supportedModels;

  CarPartDetail({
    required this.partName,
    required this.condition,
    required this.brandName,
    required this.supportedModels,
  });

  factory CarPartDetail.fromJson(Map<String, dynamic> json) {
    return CarPartDetail(
      partName: json['part_name'] ?? '',
      condition: json['condition'] ?? '',
      brandName: json['brand_name'] ?? '',
      supportedModels: List<String>.from(json['supported_model'] ?? []),
    );
  }
}

// باقي الكلاسات (User, Comment, SimilarAd) زي اللي عندك
class User {
  final int id;
  final String username;
  final String phoneNumber;
  final String email;
  final String profilePictureUrl;

  User({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }
}

class Comment {
  final int id;
  final String text;
  final String userName;
  final String userPicture;

  Comment({
    required this.id,
    required this.text,
    required this.userName,
    required this.userPicture,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['comment_id'],
      text: json['comment_text'] ?? '',
      userName: json['user_name'] ?? '',
      userPicture: json['user_picture'] ?? '',
    );
  }
}

class SimilarAd {
  final int id;
  final String title;
  final String price;
  final String brandName;
  final List<String> imageUrls;

  SimilarAd({
    required this.id,
    required this.title,
    required this.price,
    required this.brandName,
    required this.imageUrls,
  });

  factory SimilarAd.fromJson(Map<String, dynamic> json) {
    return SimilarAd(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      brandName: json['brand_name'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }
}