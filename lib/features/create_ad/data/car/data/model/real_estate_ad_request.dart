import 'dart:io';

class RealEstateAdRequest {
  final String title;
  final String description;
  final num price;
  final String priceType;        // fixed | negotiable | auction

  final int categoryId;          // ثابت = 2
  final int cityId;
  final int regionId;
  final double latitude;
  final double longitude;

  final String realEstateType;   // villa | apartment | land | ...
  final String purpose;          // sell | rent

  // اختياري
  final num? areaM2;
  final int? streetCount;
  final int? floorCount;
  final int? roomCount;
  final int? bathroomCount;
  final int? livingroomCount;
  final num? streetWidth;
  final String? facade;          // north | south | east | west
  final String? buildingAge;     // new | used | old
  final bool? isFurnished;
  final String? licenseNumber;
  final List<String>? services;  // ['electricity', 'water']
  final int? exhibitionId;

  final List<File> images;

  RealEstateAdRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.priceType,
    this.categoryId = 2, // ✅ تم التعديل إلى 2 (فئة العقارات)
    required this.cityId,
    required this.regionId,
    required this.latitude,
    required this.longitude,
    required this.realEstateType,
    required this.purpose,
    this.areaM2,
    this.streetCount,
    this.floorCount,
    this.roomCount,
    this.bathroomCount,
    this.livingroomCount,
    this.streetWidth,
    this.facade,
    this.buildingAge,
    this.isFurnished,
    this.licenseNumber,
    this.services,
    this.exhibitionId,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'price': price,
      'price_type': priceType,
      'category_id': categoryId,
      'city_id': cityId,
      'region_id': regionId,
      'latitude': latitude,
      'longitude': longitude,
      'real_estate_type': realEstateType,
      'purpose': purpose,
    };

    void put(String k, dynamic v) { if (v != null) map[k] = v; }

    put('area_m2', areaM2);
    put('street_count', streetCount);
    put('floor_count', floorCount);
    put('room_count', roomCount);
    put('bathroom_count', bathroomCount);
    put('livingroom_count', livingroomCount);
    put('street_width', streetWidth);
    put('facade', facade);
    put('building_age', buildingAge);
    put('is_furnished', isFurnished);
    put('license_number', licenseNumber);
    put('services', services == null ? null : services); // JSON تحويل لاحق في الريبو
    put('exhibition_id', exhibitionId);
    return map;
  }
}
