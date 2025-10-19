// lib/features/create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_state.dart

import 'dart:io';

class RealEstateAdsState {
  final bool submitting;
  final bool success;
  final String? error;

  // الأساسية
  final String? title;
  final String? description;
  final num? price;
  final String priceType;

  final int? categoryId;
  final int? cityId;
  final int? regionId;
  final double? latitude;
  final double? longitude;

  final String? realEstateType;
  final String purpose; // sell | rent

  // السماح بالتعليق والتسويق
  final bool? allowComments;
  final bool? allowMarketing;

  // اختياري
  final num? areaM2;
  final int? streetCount;
  final int? floorCount;
  final int? roomCount;
  final int? bathroomCount;
  final int? livingroomCount;
  final num? streetWidth;
  final String? facade;
  final String? buildingAge;
  final bool? isFurnished;
  final String? licenseNumber;
  final List<String> services;
  final int? exhibitionId;

  final List<File> images;

  const RealEstateAdsState({
    this.submitting = false,
    this.success = false,
    this.error,

    this.title,
    this.description,
    this.price,
    this.priceType = 'fixed',

    this.categoryId,
    this.cityId,
    this.regionId,
    this.latitude,
    this.longitude,

    this.realEstateType,
    this.purpose = 'sell',

    this.allowComments = true,
    this.allowMarketing = true,

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
  });

  // Getters آمنة لقيم السويتشات
  bool get allowCommentsSafe => allowComments ?? true;
  bool get allowMarketingSafe => allowMarketing ?? true;

  RealEstateAdsState copyWith({
    bool? submitting,
    bool? success,
    String? error,

    String? title,
    String? description,
    num? price,
    String? priceType,

    int? categoryId,
    int? cityId,
    int? regionId,
    double? latitude,
    double? longitude,

    String? realEstateType,
    String? purpose,

    bool? allowComments,
    bool? allowMarketing,

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
  }) {
    return RealEstateAdsState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,

      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,

      categoryId: categoryId ?? this.categoryId,
      cityId: cityId ?? this.cityId,
      regionId: regionId ?? this.regionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,

      realEstateType: realEstateType ?? this.realEstateType,
      purpose: purpose ?? this.purpose,

      allowComments: allowComments ?? this.allowComments,
      allowMarketing: allowMarketing ?? this.allowMarketing,

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
    );
  }
}