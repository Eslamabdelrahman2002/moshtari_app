import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';

class RealEstateAuctionStartRepo {
  final ApiService _api;
  RealEstateAuctionStartRepo(this._api);

  Future<Map<String, dynamic>> start({
    required String title,
    required String description,
    required num startPrice,
    required num hiddenLimit,
    required num bidStep,
    String? startTimeIso,
    required String endTimeIso,
    required String type,
    required num minBidValue,
    required bool isAutoApproval,
    required String itemsJson,
    File? thumbnail,
    List<File> images = const [],
    List<File> pdfs = const [],
  }) async {
    final form = FormData();

    form.fields.addAll([
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('start_price', startPrice.toString()),
      MapEntry('hidden_limit', hiddenLimit.toString()),
      MapEntry('bid_step', bidStep.toString()),

      // Top-level (اختياري) — السيرفر قد يتجاهلها ويعتمد تواريخ العناصر
      if (startTimeIso != null && startTimeIso.trim().isNotEmpty)
        MapEntry('start_date', startTimeIso.trim()),
      if (endTimeIso.trim().isNotEmpty)
        MapEntry('end_date', endTimeIso.trim()),

      MapEntry('type', type),
      MapEntry('min_bid_value', minBidValue.toString()),
      MapEntry('is_auto_approval', isAutoApproval ? 'true' : 'false'),
      MapEntry('items', itemsJson),
    ]);

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
        'image_urls_$i',
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
        'pdf_file_$i',
        await MultipartFile.fromFile(
          f.path,
          filename: _filename(f.path, prefix: 'doc_$i'),
          contentType: MediaType('application', 'pdf'),
        ),
      ));
    }

    // Debug
    // ignore: avoid_print
    for (final e in form.fields) {
      if (e.key == 'items') {
        print('FIELD ${e.key}=${e.value.substring(0, e.value.length.clamp(0, 400))}...');
      } else {
        print('FIELD ${e.key}=${e.value}');
      }
    }
    // ignore: avoid_print
    for (final e in form.files) {
      print('FILE ${e.key} -> ${e.value.filename}');
    }

    final resp = await _api.postForm(ApiConstants.realEstateAuctionsStart, form,requireAuth: true);
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