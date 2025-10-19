import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

class CarAuctionStartRepo {
  final ApiService _api;
  CarAuctionStartRepo(this._api);

  Future<Map<String, dynamic>> start({
    required String type,
    required String title,
    required String description,
    required bool isAutoApproval,
    String? startDateIso,
    required String endDateIso,
    required num minBidValue,
    required String itemsJson,
    File? thumbnail,
    List<File> images = const [],
    List<File> pdfs = const [],
  }) async {
    final form = FormData();
    form.fields.addAll([
      MapEntry('type', type),
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('is_auto_approval', isAutoApproval.toString()),
      if (startDateIso != null) MapEntry('start_date', startDateIso),
      MapEntry('end_date', endDateIso),
      MapEntry('min_bid_value', minBidValue.toString()),
      MapEntry('items', itemsJson),
    ]);

    if (thumbnail != null) {
      form.files.add(MapEntry('thumbnail', await MultipartFile.fromFile(thumbnail.path)));
    }
    for (int i = 0; i < images.length; i++) {
      form.files.add(MapEntry('image_urls_$i', await MultipartFile.fromFile(images[i].path)));
    }
    for (int i = 0; i < pdfs.length; i++) {
      form.files.add(MapEntry('pdf_file_$i', await MultipartFile.fromFile(pdfs[i].path)));
    }

    // استخدم postForm بدلاً من post
    final resp = await _api.postForm(ApiConstants.carAuctionsStart, form);
    return resp;
  }
}