// lib/features/create_ad/ui/screens/cars/logic/cubit/car_ads_state.dart
import 'dart:io';

class CarAdsState {
  // الحقول الأساسية
  final String? title;
  final String? description;
  final num? price;
  final String priceType;

  final int? categoryId;
  final int? cityId;
  final int? regionId;

  final double? latitude;
  final double? longitude;
  final String? addressAr; // 🟢 تمت إضافته (للعرض في الواجهة)
  final String? phone; // 🟢 تمت إضافته

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
  final bool contactChat; // 🟢 تمت إضافته
  final bool contactWhatsapp; // 🟢 تمت إضافته
  final bool contactCall; // 🟢 تمت إضافته

  final List<File> images;
  final File? technicalReport;

  // التحكم بالطلب
  final bool submitting;
  final bool success;
  final String? error;

  CarAdsState({
    this.title,
    this.description,
    this.price,
    this.priceType = 'fixed',

    this.categoryId,
    this.cityId,
    this.regionId,

    this.latitude,
    this.longitude,
    this.addressAr, // 🟢 تمت إضافته
    this.phone, // 🟢 تمت إضافته

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
    this.contactChat = true, // 🟢 تمت إضافته
    this.contactWhatsapp = true, // 🟢 تمت إضافته
    this.contactCall = true, // 🟢 تمت إضافته

    this.images = const [],
    this.technicalReport,

    this.submitting = false,
    this.success = false,
    this.error,
  });

  CarAdsState copyWith({
    String? title,
    String? description,
    num? price,
    String? priceType,

    int? categoryId,
    int? cityId,
    int? regionId,

    double? latitude,
    double? longitude,
    String? addressAr, // 🟢 تمت إضافته
    String? phone, // 🟢 تمت إضافته

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
    bool? contactChat, // 🟢 تمت إضافته
    bool? contactWhatsapp, // 🟢 تمت إضافته
    bool? contactCall, // 🟢 تمت إضافته

    List<File>? images,
    File? technicalReport,

    bool? submitting,
    bool? success,
    String? error,
    bool clearError = false, // لاستخدام مسح الخطأ
  }) {
    return CarAdsState(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,

      categoryId: categoryId ?? this.categoryId,
      cityId: cityId ?? this.cityId,
      regionId: regionId ?? this.regionId,

      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressAr: addressAr ?? this.addressAr, // 🟢 تمت إضافته
      phone: phone ?? this.phone, // 🟢 تمت إضافته

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
      contactChat: contactChat ?? this.contactChat, // 🟢 تمت إضافته
      contactWhatsapp: contactWhatsapp ?? this.contactWhatsapp, // 🟢 تمت إضافته
      contactCall: contactCall ?? this.contactCall, // 🟢 تمت إضافته

      images: images ?? this.images,
      technicalReport: technicalReport ?? this.technicalReport,

      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }
}