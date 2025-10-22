// lib/features/create_ad/data/car/data/model/car_part_ad_request.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:path/path.dart' as p;

class CarPartAdRequest {
  final String title;
  final String partName;
  final String condition; // new | used
  final int? brandId;
  final List<String>? supportedModel;
  final String? description;

  final num price;
  final String priceType; // fixed | negotiable | auction

  final int cityId;
  final int? neighborhoodId;
  final int? regionId;
  final String? phoneNumber;
  final List<String>? communicationMethods;
  final bool allowMarketing;
  final bool allowComments;
  final int? exhibitionId;

  final double? latitude;
  final double? longitude;

  // تم تغييره ليكون 2 افتراضيًا
  final int categoryId; // = 2
  final List<File> images;

  CarPartAdRequest({
    required this.title,
    required this.partName,
    required this.condition,
    this.brandId,
    this.supportedModel,
    this.description,
    required this.price,
    required this.priceType,
    required this.cityId,
    this.neighborhoodId,
    this.regionId,
    this.phoneNumber,
    this.communicationMethods,
    this.allowMarketing = true,
    this.allowComments = true,
    this.exhibitionId,
    this.latitude,
    this.longitude,
    this.categoryId = 2, // ← هنا التغيير
    required this.images,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'title': title,
      'part_name': partName,
      'condition': condition,
      if (brandId != null) 'brand_id': brandId,
      if (supportedModel != null) 'supported_model': jsonEncode(supportedModel),
      if (description != null) 'description': description,
      'price': price,
      'price_type': priceType,
      'city_id': cityId,
      if (regionId != null) 'region_id': regionId,
      if (neighborhoodId != null) 'neighborhood_id': neighborhoodId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (communicationMethods != null)
        'communication_methods': jsonEncode(communicationMethods),
      'allow_marketing': allowMarketing,
      'allow_comments': allowComments,
      if (exhibitionId != null) 'exhibition_id': exhibitionId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'category_id': categoryId, // ← هيرسل 2 افتراضيًا
      'type': 'car_part',
    };

    final form = FormData.fromMap(map);

    for (final f in images) {
      form.files.add(
        MapEntry(
          ApiConstants.carPartImagesKey, // غالبًا 'image_urls'
          await MultipartFile.fromFile(
            f.path,
            filename: p.basename(f.path),
          ),
        ),
      );
    }
    return form;
  }
}