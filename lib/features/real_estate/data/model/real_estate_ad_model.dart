class RealEstateListModel {
  final int id;
  final String? title;
  final String? price;
  final String? priceType;
  final String? realEstateType;
  final String? purpose;
  final int? roomCount;
  final int? bathroomCount;
  final int? cityId;
  final String? cityName;
  final int? regionId;
  final String? regionName;
  final int? userId;
  final String? username;
  final String? profilePicture;
  final List<String>? imageUrls;
  final DateTime? createdAt;

  RealEstateListModel({
    required this.id,
    this.title,
    this.price,
    this.priceType,
    this.realEstateType,
    this.purpose,
    this.roomCount,
    this.bathroomCount,
    this.cityId,
    this.cityName,
    this.regionId,
    this.regionName,
    this.userId,
    this.username,
    this.profilePicture,
    this.imageUrls,
    this.createdAt,
  });

  factory RealEstateListModel.fromJson(Map<String, dynamic> json) {
    return RealEstateListModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      price: json['price'] as String?,
      priceType: json['price_type'] as String?,
      realEstateType: json['real_estate_type'] as String?,
      purpose: json['purpose'] as String?,
      roomCount: json['room_count'] as int?,
      bathroomCount: json['bathroom_count'] as int?,
      cityId: json['city_id'] as int?,
      cityName: json['city_name'] as String?,
      regionId: json['region_id'] as int?,
      regionName: json['region_name'] as String?,
      userId: json['user_id'] as int?,
      username: json['username'] as String?,
      profilePicture: json['profile_picture'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}