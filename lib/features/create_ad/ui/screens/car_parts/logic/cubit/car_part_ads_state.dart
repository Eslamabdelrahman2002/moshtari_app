import 'dart:io';

class CarPartAdsState {
  final String? title;
  final String? partName;
  final String condition; // new | used
  final int? brandId;
  final List<String> supportedModel;
  final String? description;

  final num? price;
  final String priceType; // fixed | negotiable | auction

  final int? cityId;
  final int? neighborhoodId;
  final int? regionId; // 🟢 تمت الإضافة
  final String? phoneNumber;
  final List<String> communicationMethods;
  final bool allowMarketing;
  final bool allowComments;
  final int? exhibitionId;
  final double? latitude;
  final double? longitude;

  final List<File> images;

  final bool submitting;
  final bool success;
  final String? error;

  CarPartAdsState({
    this.title,
    this.partName,
    this.condition = 'used',
    this.brandId,
    this.supportedModel = const [],
    this.description,
    this.price,
    this.priceType = 'fixed',
    this.cityId,
    this.neighborhoodId,
    this.regionId, // 🟢 تمت الإضافة
    this.phoneNumber,
    this.communicationMethods = const ['chat', 'call'],
    this.allowMarketing = true,
    this.allowComments = true,
    this.exhibitionId,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.submitting = false,
    this.success = false,
    this.error,
  });

  CarPartAdsState copyWith({
    String? title,
    String? partName,
    String? condition,
    int? brandId,
    List<String>? supportedModel,
    String? description,
    num? price,
    String? priceType,
    int? cityId,
    int? neighborhoodId,
    int? regionId, // 🟢 تمت الإضافة
    String? phoneNumber,
    List<String>? communicationMethods,
    bool? allowMarketing,
    bool? allowComments,
    int? exhibitionId,
    double? latitude,
    double? longitude,
    List<File>? images,
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return CarPartAdsState(
      title: title ?? this.title,
      partName: partName ?? this.partName,
      condition: condition ?? this.condition,
      brandId: brandId ?? this.brandId,
      supportedModel: supportedModel ?? this.supportedModel,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      cityId: cityId ?? this.cityId,
      neighborhoodId: neighborhoodId ?? this.neighborhoodId,
      regionId: regionId ?? this.regionId, // 🟢 تمت الإضافة
      phoneNumber: phoneNumber ?? this.phoneNumber,
      communicationMethods: communicationMethods ?? this.communicationMethods,
      allowMarketing: allowMarketing ?? this.allowMarketing,
      allowComments: allowComments ?? this.allowComments,
      exhibitionId: exhibitionId ?? this.exhibitionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }
}