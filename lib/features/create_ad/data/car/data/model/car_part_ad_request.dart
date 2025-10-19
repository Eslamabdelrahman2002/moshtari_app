import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/top_level_categories.dart';

class CarPartAdRequest {
  final String title;
  final String partName;
  final String condition; // new | used
  final int? brandId;
  final List<String>? supportedModel; // ["2021", "2022"]
  final String? description;

  final num price;
  final String priceType; // fixed | negotiable | auction

  final int cityId;
  final int? neighborhoodId;
  final int? regionId; // 🟢 تمت الإضافة
  final String? phoneNumber;
  final List<String>? communicationMethods; // ["chat","call"]
  final bool allowMarketing;
  final bool allowComments;
  final int? exhibitionId;

  final double? latitude;
  final double? longitude;

  final int categoryId; // ثابت= 3 (قطع غيار)
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
    this.regionId, // 🟢 تمت الإضافة
    this.phoneNumber,
    this.communicationMethods,
    this.allowMarketing = true,
    this.allowComments = true,
    this.exhibitionId,
    this.latitude,
    this.longitude,
    // ✅ القيمة الصحيحة لقطع الغيار هي 3، لذا هذا السطر صحيح (بافتراض قيمة carParts = 3)
    this.categoryId = TopLevelCategoryIds.carParts,
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
      if (regionId != null) 'region_id': regionId, // 🟢 تمت الإضافة
      if (neighborhoodId != null) 'neighborhood_id': neighborhoodId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (communicationMethods != null)
        'communication_methods': jsonEncode(communicationMethods),
      'allow_marketing': allowMarketing,
      'allow_comments': allowComments,
      if (exhibitionId != null) 'exhibition_id': exhibitionId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'category_id': categoryId,
    };

    final form = FormData.fromMap(map);

    for (final f in images) {
      form.files.add(
        MapEntry(
          ApiConstants.carPartImagesKey,
          await MultipartFile.fromFile(f.path),
        ),
      );
    }
    return form;
  }
}