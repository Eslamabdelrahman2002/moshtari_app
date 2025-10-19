import 'dart:convert';

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse('$v') ?? 0;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.tryParse('$v');
  } catch (_) {
    return null;
  }
}

class ExhibitionsListResponse {
  final bool success;
  final String message;
  final List<ExhibitionItem> data;

  ExhibitionsListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExhibitionsListResponse.fromJson(Map<String, dynamic> j) {
    final list = <ExhibitionItem>[];
    if (j['data'] is List) {
      for (final e in (j['data'] as List)) {
        list.add(ExhibitionItem.fromJson(e as Map<String, dynamic>));
      }
    }
    return ExhibitionsListResponse(
      success: j['success'] == true,
      message: (j['message'] ?? '').toString(),
      data: list,
    );
  }

  static ExhibitionsListResponse fromRaw(String raw) =>
      ExhibitionsListResponse.fromJson(json.decode(raw));
}

class ExhibitionItem {
  final int id;
  final String name;
  final String activityType;
  final String phoneNumber;
  final String address;
  final String imageUrl;
  final int promoterId;
  final int cityId;
  final int regionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // adCount غير موجود في هذا الـ API، هنحطه افتراضي 0 لو حبيت تعرضه
  final int adCount;

  ExhibitionItem({
    required this.id,
    required this.name,
    required this.activityType,
    required this.phoneNumber,
    required this.address,
    required this.imageUrl,
    required this.promoterId,
    required this.cityId,
    required this.regionId,
    required this.createdAt,
    required this.updatedAt,
    this.adCount = 0,
  });

  factory ExhibitionItem.fromJson(Map<String, dynamic> j) {
    return ExhibitionItem(
      id: _asInt(j['id']),
      name: (j['name'] ?? '').toString(),
      activityType: (j['activity_type'] ?? '').toString(),
      phoneNumber: (j['phone_number'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      imageUrl: (j['image_url'] ?? '').toString(),
      promoterId: _asInt(j['promoter_id']),
      cityId: _asInt(j['city_id']),
      regionId: _asInt(j['region_id']),
      createdAt: _asDate(j['created_at']),
      updatedAt: _asDate(j['updated_at']),
      adCount: _asInt(j['ad_count']), // غالباً غير موجود -> 0
    );
  }
}