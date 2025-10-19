import 'dart:convert';

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse('$v') ?? 0;
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse('$v') ?? 0.0;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.tryParse('$v');
  } catch (_) {
    return null;
  }
}

class ExhibitionDetailsResponse {
  final bool success;
  final String message;
  final ExhibitionDetailsData data;

  ExhibitionDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExhibitionDetailsResponse.fromJson(Map<String, dynamic> j) {
    return ExhibitionDetailsResponse(
      success: j['success'] == true,
      message: (j['message'] ?? '').toString(),
      data: ExhibitionDetailsData.fromJson(j['data'] ?? {}),
    );
  }

  static ExhibitionDetailsResponse fromRaw(String raw) =>
      ExhibitionDetailsResponse.fromJson(json.decode(raw));
}

class ExhibitionDetailsData {
  final int exhibitionId;
  final String exhibitionName;
  final String activityType;
  final String phoneNumber;
  final String address;
  final int cityId;
  final int regionId;
  final String imageUrl;
  final int promoterId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String username;
  final String? profilePictureUrl;
  final int adsCount;
  final List<ExhibitionAd> ads;

  ExhibitionDetailsData({
    required this.exhibitionId,
    required this.exhibitionName,
    required this.activityType,
    required this.phoneNumber,
    required this.address,
    required this.cityId,
    required this.regionId,
    required this.imageUrl,
    required this.promoterId,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.profilePictureUrl,
    required this.adsCount,
    required this.ads,
  });

  factory ExhibitionDetailsData.fromJson(Map<String, dynamic> j) {
    final ads = <ExhibitionAd>[];
    if (j['ads'] is List) {
      for (final e in (j['ads'] as List)) {
        ads.add(ExhibitionAd.fromJson(e));
      }
    }
    return ExhibitionDetailsData(
      exhibitionId: _asInt(j['exhibition_id']),
      exhibitionName: (j['exhibition_name'] ?? '').toString(),
      activityType: (j['activity_type'] ?? '').toString(),
      phoneNumber: (j['phone_number'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      cityId: _asInt(j['city_id']),
      regionId: _asInt(j['region_id']),
      imageUrl: (j['image_url'] ?? '').toString(),
      promoterId: _asInt(j['promoter_id']),
      createdAt: _asDate(j['created_at']),
      updatedAt: _asDate(j['updated_at']),
      username: (j['username'] ?? '').toString(),
      profilePictureUrl: (j['profile_picture_url'] ?? '').toString(),
      adsCount: _asInt(j['ads_count']),
      ads: ads,
    );
  }
}

class ExhibitionAd {
  final int adId;
  final String adTitle;
  final List<String> imageUrls;
  final double price;
  final int cityId;
  final int regionId;
  final DateTime? adDate;

  ExhibitionAd({
    required this.adId,
    required this.adTitle,
    required this.imageUrls,
    required this.price,
    required this.cityId,
    required this.regionId,
    required this.adDate,
  });

  factory ExhibitionAd.fromJson(Map<String, dynamic> j) {
    final imgs = <String>[];
    if (j['image_urls'] is List) {
      for (final e in (j['image_urls'] as List)) {
        imgs.add('$e');
      }
    }
    return ExhibitionAd(
      adId: _asInt(j['ad_id']),
      adTitle: (j['ad_title'] ?? '').toString(),
      imageUrls: imgs,
      price: _asDouble(j['price']),
      cityId: _asInt(j['city_id']),
      regionId: _asInt(j['region_id']),
      adDate: _asDate(j['ad_date']),
    );
  }
}