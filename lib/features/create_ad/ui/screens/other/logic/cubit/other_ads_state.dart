// features/create_ad/ui/screens/other/logic/cubit/other_ads_state.dart
import 'dart:io';

class OtherAdsState {
  final String? title;
  final String? description;

  final int? categoryId;
  final String priceType; // fixed | negotiable | auction
  final num? price;

  final int? cityId;
  final int? regionId;
  final String? locationName;

  final String? phoneNumber;
  final List<String> communicationMethods;

  final bool allowMarketing;
  final bool allowComments;

  final double? latitude;
  final double? longitude;

  final List<File> images;

  final bool submitting;
  final bool success;
  final String? error;

  const OtherAdsState({
    this.title,
    this.description,
    this.categoryId,
    this.priceType = 'fixed',
    this.price,
    this.cityId,
    this.regionId,
    this.locationName,
    this.phoneNumber,
    this.communicationMethods = const [],
    this.allowMarketing = true,
    this.allowComments = true,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.submitting = false,
    this.success = false,
    this.error,
  });

  OtherAdsState copyWith({
    String? title,
    String? description,
    int? categoryId,
    String? priceType,
    num? price,
    int? cityId,
    int? regionId,
    String? locationName,
    String? phoneNumber,
    List<String>? communicationMethods,
    bool? allowMarketing,
    bool? allowComments,
    double? latitude,
    double? longitude,
    List<File>? images,
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return OtherAdsState(
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priceType: priceType ?? this.priceType,
      price: price ?? this.price,
      cityId: cityId ?? this.cityId,
      regionId: regionId ?? this.regionId,
      locationName: locationName ?? this.locationName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      communicationMethods: communicationMethods ?? this.communicationMethods,
      allowMarketing: allowMarketing ?? this.allowMarketing,
      allowComments: allowComments ?? this.allowComments,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }
}