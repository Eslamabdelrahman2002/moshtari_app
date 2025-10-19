import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';

class OtherAdRequest {
  final String title;
  final String? description;

  final int categoryId;
  final String priceType; // fixed | negotiable | auction
  final num? price;

  final int cityId;
  final int? regionId;
  final String? locationName;

  final String? phoneNumber;
  final List<String>? communicationMethods; // ["chat","whatsapp","phone"]

  final bool allowMarketing;
  final bool allowComments;

  final double? latitude;
  final double? longitude;

  final List<File> images;

  OtherAdRequest({
    required this.title,
    this.description,
    required this.categoryId,
    required this.priceType,
    this.price,
    required this.cityId,
    this.regionId,
    this.locationName,
    this.phoneNumber,
    this.communicationMethods,
    this.allowMarketing = true,
    this.allowComments = true,
    this.latitude,
    this.longitude,
    this.images = const [],
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'title': title,
      if (description != null) 'description': description,
      'category_id': categoryId,
      'price_type': priceType,
      if (price != null) 'price': price,
      'city_id': cityId,
      if (regionId != null) 'region_id': regionId,
      if (locationName != null) 'location_name': locationName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (communicationMethods != null)
        'communication_methods': jsonEncode(communicationMethods),
      'allow_marketing': allowMarketing,
      'allow_comments': allowComments,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final form = FormData.fromMap(map);

    for (final f in images) {
      form.files.add(
        MapEntry(
          ApiConstants.otherAdImagesKey,
          await MultipartFile.fromFile(f.path),
        ),
      );
    }
    return form;
  }
}