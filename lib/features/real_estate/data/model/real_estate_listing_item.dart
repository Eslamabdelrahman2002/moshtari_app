// file: real_estate_listing_item.dart (تم تغيير الاسم داخلياً ليصبح RealEstateListModel)

// ✅ FIX: تغيير اسم الكلاس ليطابق توقعات الواجهة
class RealEstateListModel {
  final int id;
  final String? title;
  final String? price;
  final String? priceType;
  final String? realEstateType; // apartment | villa | land | office | ...
  final String? purpose;        // sell | rent
  final int? roomCount;
  final int? bathroomCount;
  final int? cityId;
  final String? cityName;
  final int? regionId;
  final String? regionName;
  final String? username;
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
    this.username,
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
      username: json['username'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}