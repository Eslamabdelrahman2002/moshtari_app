// lib/features/create_ad/ui/screens/other/logic/cubit/other_ads_state.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

class OtherAdsState extends Equatable {
  final bool submitting;
  final bool success;
  final String? error;

  final String? title;
  final String? description;
  final int? subCategoryId;
  final int? regionId;
  final int? cityId;
  final num? price;
  final String? phone;
  final String priceType; // default: 'fixed'

  final bool allowComments;
  final bool allowMarketing;

  final List<String> communicationMethods;
  final List<File> images;

  const OtherAdsState({
    this.submitting = false,
    this.success = false,
    this.error,

    this.title,
    this.description,
    this.subCategoryId,
    this.regionId,
    this.cityId,
    this.price,
    this.phone,
    this.priceType = 'fixed',

    this.allowComments = true,
    this.allowMarketing = true,

    this.communicationMethods = const [],
    this.images = const [],
  });

  OtherAdsState copyWith({
    bool? submitting,
    bool? success,
    String? error,

    String? title,
    String? description,
    int? subCategoryId,
    int? regionId,
    int? cityId,
    num? price,
    String? phone,
    String? priceType,

    bool? allowComments,
    bool? allowMarketing,

    List<String>? communicationMethods,
    List<File>? images,
  }) {
    return OtherAdsState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,

      title: title ?? this.title,
      description: description ?? this.description,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      regionId: regionId ?? this.regionId,
      cityId: cityId ?? this.cityId,
      price: price ?? this.price,
      phone: phone ?? this.phone,
      priceType: priceType ?? this.priceType,

      allowComments: allowComments ?? this.allowComments,
      allowMarketing: allowMarketing ?? this.allowMarketing,

      communicationMethods: communicationMethods ?? this.communicationMethods,
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [
    submitting, success, error,
    title, description, subCategoryId, regionId, cityId,
    price, phone, priceType,
    allowComments, allowMarketing,
    communicationMethods, images,
  ];
}