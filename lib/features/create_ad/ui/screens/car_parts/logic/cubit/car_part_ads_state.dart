import 'dart:io';

class CarPartAdsState {
  // وضع التعديل
  final bool isEditing;
  final int? editingAdId;

  // حقول الطلب
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
  final int? regionId;
  final String? phoneNumber;
  final List<String> communicationMethods;
  final bool allowMarketing;
  final bool allowComments;
  final int? exhibitionId;
  final double? latitude;
  final double? longitude;

  // الوسائط
  final List<File> images;             // صور جديدة (ملفات)
  final List<String> existingImageUrls; // صور قديمة (روابط)

  // حالة الإرسال
  final bool submitting;
  final bool success;
  final String? error;

  CarPartAdsState({
    this.isEditing = false,
    this.editingAdId,
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
    this.regionId,
    this.phoneNumber,
    this.communicationMethods = const ['chat', 'call'],
    this.allowMarketing = true,
    this.allowComments = true,
    this.exhibitionId,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.existingImageUrls = const [],
    this.submitting = false,
    this.success = false,
    this.error,
  });

  CarPartAdsState copyWith({
    bool? isEditing,
    int? editingAdId,
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
    int? regionId,
    String? phoneNumber,
    List<String>? communicationMethods,
    bool? allowMarketing,
    bool? allowComments,
    int? exhibitionId,
    double? latitude,
    double? longitude,
    List<File>? images,
    List<String>? existingImageUrls,
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return CarPartAdsState(
      isEditing: isEditing ?? this.isEditing,
      editingAdId: editingAdId ?? this.editingAdId,
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
      regionId: regionId ?? this.regionId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      communicationMethods: communicationMethods ?? this.communicationMethods,
      allowMarketing: allowMarketing ?? this.allowMarketing,
      allowComments: allowComments ?? this.allowComments,
      exhibitionId: exhibitionId ?? this.exhibitionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }
}