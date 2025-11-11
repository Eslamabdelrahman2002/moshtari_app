// lib/features/create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_state.dart
import 'dart:io';

class RealEstateAdsState {
  // حقول أساسية
  final String? title;
  final String? description;
  final num? price;
  final String priceType; // fixed/negotiable/auction

  // الموقع
  final int? cityId;
  final int? regionId;
  final double? latitude;
  final double? longitude;

  // نوع / غرض العقار
  final String? realEstateType; // API value
  final String? purpose; // 'sell' or 'rent'

  // تفاصيل إضافية
  final num? areaM2;
  final int? streetCount;
  final int? floorCount;
  final int? roomCount;
  final int? bathroomCount;
  final int? livingroomCount;
  final num? streetWidth;
  final String? facade; // north/south/...
  final String? buildingAge; // new/used/old
  final bool? isFurnished;
  final String? licenseNumber;
  final List<String> services;

  // معرض
  final int? exhibitionId;

  // صور جديدة فقط (ملفات)
  final List<File> images;

  // صور موجودة مسبقاً (روابط كـ string مفصول بفواصل للإرسال إلى API)
  final String? existingImageUrls; // تعديل: من List<String> إلى String? (مثل "url1,url2")

  // سويتشات
  final bool allowComments;
  final bool allowMarketing;

  // حالة الإرسال
  final bool submitting;
  final bool success;
  final String? error;

  // وضع التعديل
  final bool isEditing;
  final int? editingAdId;

  // أسماء مبدئية للمنطقة/المدينة للمقارنة والاختيار التلقائي
  final String? preselectedRegionName;
  final String? preselectedCityName;

  const RealEstateAdsState({
    this.title,
    this.description,
    this.price,
    this.priceType = '',
    this.cityId,
    this.regionId,
    this.latitude,
    this.longitude,
    this.realEstateType,
    this.purpose,
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
    this.services = const [],
    this.exhibitionId,
    this.images = const [],
    this.existingImageUrls, // تعديل: String?
    this.allowComments = true,
    this.allowMarketing = true,
    this.submitting = false,
    this.success = false,
    this.error,
    this.isEditing = false,
    this.editingAdId,
    this.preselectedRegionName,
    this.preselectedCityName,
  });

  RealEstateAdsState copyWith({
    String? title,
    String? description,
    num? price,
    String? priceType,
    int? cityId,
    int? regionId,
    double? latitude,
    double? longitude,
    String? realEstateType,
    String? purpose,
    num? areaM2,
    int? streetCount,
    int? floorCount,
    int? roomCount,
    int? bathroomCount,
    int? livingroomCount,
    num? streetWidth,
    String? facade,
    String? buildingAge,
    bool? isFurnished,
    String? licenseNumber,
    List<String>? services,
    int? exhibitionId,
    List<File>? images,
    String? existingImageUrls, // تعديل: String?
    bool? allowComments,
    bool? allowMarketing,
    bool? submitting,
    bool? success,
    String? error,
    bool? isEditing,
    int? editingAdId,
    String? preselectedRegionName,
    String? preselectedCityName,
  }) {
    return RealEstateAdsState(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      cityId: cityId ?? this.cityId,
      regionId: regionId ?? this.regionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      realEstateType: realEstateType ?? this.realEstateType,
      purpose: purpose ?? this.purpose,
      areaM2: areaM2 ?? this.areaM2,
      streetCount: streetCount ?? this.streetCount,
      floorCount: floorCount ?? this.floorCount,
      roomCount: roomCount ?? this.roomCount,
      bathroomCount: bathroomCount ?? this.bathroomCount,
      livingroomCount: livingroomCount ?? this.livingroomCount,
      streetWidth: streetWidth ?? this.streetWidth,
      facade: facade ?? this.facade,
      buildingAge: buildingAge ?? this.buildingAge,
      isFurnished: isFurnished ?? this.isFurnished,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      services: services ?? this.services,
      exhibitionId: exhibitionId ?? this.exhibitionId,
      images: images ?? this.images,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls, // تعديل: String?
      allowComments: allowComments ?? this.allowComments,
      allowMarketing: allowMarketing ?? this.allowMarketing,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      editingAdId: editingAdId ?? this.editingAdId,
      preselectedRegionName: preselectedRegionName ?? this.preselectedRegionName,
      preselectedCityName: preselectedCityName ?? this.preselectedCityName,
    );
  }
}