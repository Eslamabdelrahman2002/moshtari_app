import 'dart:io';

class CarAdsState {
  // ...
  final bool isEditing;
  final int? editingAdId;

  final String? title;
  final String? description;
  final num? price;
  final String priceType;

  final int categoryId;
  final int? cityId;
  final int? regionId;
  final double? latitude;
  final double? longitude;
  final String? addressAr;
  final String? phone;

  final bool contactChat;
  final bool contactWhatsapp;
  final bool contactCall;

  final String condition;
  final String saleType;
  final String warranty;
  final num? mileage;
  final String transmission;
  final int? cylinders;
  final String? color;
  final String fuelType;
  final String driveType;
  final int? horsepower;
  final String doors;
  final String? vehicleType;
  final int? brandId;
  final int? modelId;
  final int? year;

  final bool allowComments;
  final bool allowMarketing;

  final List<File> images;
  final File? technicalReport;

  // ✅ جديد: صور قديمة (من السيرفر)
  final List<String> existingImageUrls;

  final bool submitting;
  final bool success;
  final String? error;
  final bool? clearError;

  const CarAdsState({
    this.isEditing = false,
    this.editingAdId,
    this.title,
    this.description,
    this.price,
    this.priceType = 'fixed',
    this.categoryId = 1,
    this.cityId,
    this.regionId,
    this.latitude,
    this.longitude,
    this.addressAr,
    this.phone,
    this.contactChat = true,
    this.contactWhatsapp = true,
    this.contactCall = true,
    this.condition = '',
    this.saleType = '',
    this.warranty = '',
    this.mileage,
    this.transmission = '',
    this.cylinders,
    this.color,
    this.fuelType = '',
    this.driveType = '',
    this.horsepower,
    this.doors = '',
    this.vehicleType,
    this.brandId,
    this.modelId,
    this.year,
    this.allowComments = true,
    this.allowMarketing = false,
    this.images = const [],
    this.technicalReport,
    this.existingImageUrls = const [], // ✅
    this.submitting = false,
    this.success = false,
    this.error,
    this.clearError,
  });

  CarAdsState copyWith({
    bool? isEditing,
    int? editingAdId,
    String? title,
    String? description,
    num? price,
    String? priceType,
    int? categoryId,
    int? cityId,
    int? regionId,
    double? latitude,
    double? longitude,
    String? addressAr,
    String? phone,
    bool? contactChat,
    bool? contactWhatsapp,
    bool? contactCall,
    String? condition,
    String? saleType,
    String? warranty,
    num? mileage,
    String? transmission,
    int? cylinders,
    String? color,
    String? fuelType,
    String? driveType,
    int? horsepower,
    String? doors,
    String? vehicleType,
    int? brandId,
    int? modelId,
    int? year,
    bool? allowComments,
    bool? allowMarketing,
    List<File>? images,
    File? technicalReport,
    List<String>? existingImageUrls, // ✅
    bool? submitting,
    bool? success,
    String? error,
    bool? clearError,
  }) {
    return CarAdsState(
      isEditing: isEditing ?? this.isEditing,
      editingAdId: editingAdId ?? this.editingAdId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      categoryId: categoryId ?? this.categoryId,
      cityId: cityId ?? this.cityId,
      regionId: regionId ?? this.regionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressAr: addressAr ?? this.addressAr,
      phone: phone ?? this.phone,
      contactChat: contactChat ?? this.contactChat,
      contactWhatsapp: contactWhatsapp ?? this.contactWhatsapp,
      contactCall: contactCall ?? this.contactCall,
      condition: condition ?? this.condition,
      saleType: saleType ?? this.saleType,
      warranty: warranty ?? this.warranty,
      mileage: mileage ?? this.mileage,
      transmission: transmission ?? this.transmission,
      cylinders: cylinders ?? this.cylinders,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      driveType: driveType ?? this.driveType,
      horsepower: horsepower ?? this.horsepower,
      doors: doors ?? this.doors,
      vehicleType: vehicleType ?? this.vehicleType,
      brandId: brandId ?? this.brandId,
      modelId: modelId ?? this.modelId,
      year: year ?? this.year,
      allowComments: allowComments ?? this.allowComments,
      allowMarketing: allowMarketing ?? this.allowMarketing,
      images: images ?? this.images,
      technicalReport: technicalReport ?? this.technicalReport,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls, // ✅
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
      clearError: clearError,
    );
  }
}