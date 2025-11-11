import '../../../product_details/data/model/offer_model.dart';

class RealEstateResponse {
  final bool success;
  final String message;
  final RealEstateDetailsModel? data;

  RealEstateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RealEstateResponse.fromJson(Map<String, dynamic> json) {
    return RealEstateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? RealEstateDetailsModel.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class RealEstateDetailsModel {
  final int id;
  final String title;
  final List<OfferModel> offers;
  final String description;
  final num? price; // 👈 كرقم بدل String
  final String priceType;
  final List<String> imageUrls;
  final String latitude;
  final String longitude;
  final DateTime createdAt; // 👈 بدل String
  final bool allowComments;
  final bool allowMarketingOffers;
  final User? user;
  final String city;
  final String region;
  final RealEstateDetails? realEstateDetails;
  final List<dynamic> comments;
  final List<SimilarAd> similarAds;

  RealEstateDetailsModel({
    required this.offers,
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.priceType,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.allowComments,
    required this.allowMarketingOffers,
    this.user,
    required this.city,
    required this.region,
    this.realEstateDetails,
    required this.comments,
    required this.similarAds,
  });

  factory RealEstateDetailsModel.fromJson(Map<String, dynamic> json) {
    return RealEstateDetailsModel(
      offers: (json['offers'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => OfferModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      priceType: json['price_type'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      allowComments: json['allow_comments'] ?? false,
      allowMarketingOffers: json['allow_marketing_offers'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      realEstateDetails: json['real_estate_details'] != null
          ? RealEstateDetails.fromJson(json['real_estate_details'])
          : null,
      comments: List<dynamic>.from(json['comments'] ?? []),
      similarAds: (json['similarAds'] as List? ?? [])
          .map((e) => SimilarAd.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "price": price,
      "price_type": priceType,
      "image_urls": imageUrls,
      "latitude": latitude,
      "longitude": longitude,
      "created_at": createdAt.toIso8601String(),
      "allow_comments": allowComments,
      "allow_marketing_offers": allowMarketingOffers,
      "user": user?.toJson(),
      "city": city,
      "region": region,
      "real_estate_details": realEstateDetails?.toJson(),
      "comments": comments,
      "similarAds": similarAds.map((e) => e.toJson()).toList(),
    };
  }
}

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
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "phone_number": phoneNumber,
      "email": email,
      "profile_picture_url": profilePictureUrl,
    };
  }
}

class RealEstateDetails {
  final String realEstateType;
  final String purpose;
  final int areaM2;
  final int streetCount;
  final int floorCount;
  final int roomCount;
  final int bathroomCount;
  final int livingroomCount;
  final int streetWidth;
  final String facade;
  final String buildingAge;
  final bool isFurnished;
  final String licenseNumber;
  final List<String> services;

  RealEstateDetails({
    required this.realEstateType,
    required this.purpose,
    required this.areaM2,
    required this.streetCount,
    required this.floorCount,
    required this.roomCount,
    required this.bathroomCount,
    required this.livingroomCount,
    required this.streetWidth,
    required this.facade,
    required this.buildingAge,
    required this.isFurnished,
    required this.licenseNumber,
    required this.services,
  });

  factory RealEstateDetails.fromJson(Map<String, dynamic> json) {
    return RealEstateDetails(
      realEstateType: json['real_estate_type'] ?? '',
      purpose: json['purpose'] ?? '',
      areaM2: json['area_m2'] ?? 0,
      streetCount: json['street_count'] ?? 0,
      floorCount: json['floor_count'] ?? 0,
      roomCount: json['room_count'] ?? 0,
      bathroomCount: json['bathroom_count'] ?? 0,
      livingroomCount: json['livingroom_count'] ?? 0,
      streetWidth: json['street_width'] ?? 0,
      facade: json['facade'] ?? '',
      buildingAge: json['building_age'] ?? '',
      isFurnished: json['is_furnished'] ?? false,
      licenseNumber: json['license_number'] ?? '',
      services: List<String>.from(json['services'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "real_estate_type": realEstateType,
      "purpose": purpose,
      "area_m2": areaM2,
      "street_count": streetCount,
      "floor_count": floorCount,
      "room_count": roomCount,
      "bathroom_count": bathroomCount,
      "livingroom_count": livingroomCount,
      "street_width": streetWidth,
      "facade": facade,
      "building_age": buildingAge,
      "is_furnished": isFurnished,
      "license_number": licenseNumber,
      "services": services,
    };
  }
}

class SimilarAd {
  final int id;
  final String title;
  final num? price; // 👈 كرقم بدل String
  final List<String> imageUrls;
  final String realEstateType;

  SimilarAd({
    required this.id,
    required this.title,
    this.price,
    required this.imageUrls,
    required this.realEstateType,
  });

  factory SimilarAd.fromJson(Map<String, dynamic> json) {
    return SimilarAd(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      realEstateType: json['real_estate_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "price": price,
      "image_urls": imageUrls,
      "real_estate_type": realEstateType,
    };
  }
}