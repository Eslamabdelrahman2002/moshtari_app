import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:flutter/foundation.dart';

class CarAuctionStartRepo {
  final ApiService _api;
  CarAuctionStartRepo(this._api);

  Future<Map<String, dynamic>> start({
    required String title,
    required String description,
    required String type, // single/multiple
    required bool isAutoApproval,
    String? startDateIso, // اختياري - السيرفر قد يعتمد تواريخ العناصر
    required String endDateIso,
    required num minBidValue,
    required num bidStep, // قد يكون اختياري في بعض السيرفرات
    required String itemsJson, // يجب أن يحتوي على starting_price/hidden_min_price داخل العنصر
    File? thumbnail,
    List<File> images = const [],
    List<File> pdfs = const [],
  }) async {
    final form = FormData();

    // حقول نصية عليا
    form.fields.addAll([
      MapEntry('type', type),
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('is_auto_approval', isAutoApproval ? 'true' : 'false'),
      if (startDateIso != null && startDateIso.trim().isNotEmpty)
        MapEntry('start_date', startDateIso.trim()),
      if (endDateIso.trim().isNotEmpty)
        MapEntry('end_date', endDateIso.trim()),
      MapEntry('min_bid_value', minBidValue.toString()),
      if (bidStep > 0) MapEntry('bid_step', bidStep.toString()),
      MapEntry('items', itemsJson),
    ]);

    // الملفات
    if (thumbnail != null && await thumbnail.exists()) {
      form.files.add(MapEntry(
        'thumbnail',
        await MultipartFile.fromFile(
          thumbnail.path,
          filename: _filename(thumbnail.path, prefix: 'thumbnail'),
          contentType: _imageContentType(thumbnail.path),
        ),
      ));
    }

    for (int i = 0; i < images.length; i++) {
      final f = images[i];
      if (!await f.exists()) continue;
      form.files.add(MapEntry(
        'image_urls_$i', // مطابق للـ Postman
        await MultipartFile.fromFile(
          f.path,
          filename: _filename(f.path, prefix: 'image_$i'),
          contentType: _imageContentType(f.path),
        ),
      ));
    }

    for (int i = 0; i < pdfs.length; i++) {
      final f = pdfs[i];
      if (!await f.exists()) continue;
      form.files.add(MapEntry(
        'pdf_file_$i', // مطابق للـ Postman
        await MultipartFile.fromFile(
          f.path,
          filename: _filename(f.path, prefix: 'doc_$i'),
          contentType: MediaType('application', 'pdf'),
        ),
      ));
    }

    // Debug
    debugPrint('===== CAR AUCTION FORM FIELDS =====');
    for (final e in form.fields) {
      if (e.key == 'items') {
        final v = e.value;
        final preview = v.substring(0, v.length.clamp(0, 400));
        debugPrint('FIELD ${e.key}=${preview}${v.length > 400 ? '...' : ''}');
      } else {
        debugPrint('FIELD ${e.key}=${e.value}');
      }
    }
    debugPrint('===== CAR AUCTION FORM FILES =====');
    for (final e in form.files) {
      debugPrint('FILE ${e.key} -> ${e.value.filename}');
    }

    // الطلب
    final resp = await _api.postForm(ApiConstants.carAuctionsStart, form,requireAuth: true);
    return resp;
  }

  String _filename(String path, {required String prefix}) {
    final ext = _ext(path);
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}$ext';
  }

  String _ext(String p) {
    final i = p.lastIndexOf('.');
    return i == -1 ? '' : p.substring(i);
  }

  MediaType _imageContentType(String path) {
    final ext = _ext(path).toLowerCase();
    switch (ext) {
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.jpg':
      case '.jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }
}