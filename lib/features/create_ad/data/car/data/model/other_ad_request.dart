import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class OtherAdRequest {
  final String title;                // يظهر في الاستجابة، نبقيه
  final String description;
  final int regionId;
  final int cityId;
  final num price;
  final String phone;                // سيُرسل تحت المفتاح phone_number
  final String priceType;            // 'fixed' | 'negotiable'
  final bool allowComments;
  final bool allowMarketing;
  final List<String> communicationMethods; // ['chat','phone', 'whatsapp'...]
  final List<File> images;

  // اختياري
  final String? locationName;
  final double? latitude;
  final double? longitude;

  // ملاحظة: category_id ثابت = 4 (لا حاجة لتمريره من الخارج)
  OtherAdRequest({
    required this.title,
    required this.description,
    required this.regionId,
    required this.cityId,
    required this.price,
    required this.phone,
    required this.priceType,
    required this.allowComments,
    required this.allowMarketing,
    required this.communicationMethods,
    required this.images,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'category_id': '4', // ثابت
      'price_type': priceType,
      'price': price.toString(),
      'city_id': cityId.toString(),
      'region_id': regionId.toString(),
      'phone_number': phone,
      'allow_marketing': allowMarketing.toString(), // "true"/"false"
      'allow_comments': allowComments.toString(),   // "true"/"false"
      'communication_methods': jsonEncode(communicationMethods),
    };

    if (locationName?.isNotEmpty == true) map['location_name'] = locationName!;
    if (latitude != null) map['latitude'] = latitude.toString();
    if (longitude != null) map['longitude'] = longitude.toString();

    final fd = FormData.fromMap(map);

    // الصور: كرر نفس المفتاح image_urls لكل ملف
    for (final img in images) {
      fd.files.add(MapEntry(
        'image_urls',
        await MultipartFile.fromFile(
          img.path,
          filename: p.basename(img.path),
        ),
      ));
    }

    return fd;
  }
}