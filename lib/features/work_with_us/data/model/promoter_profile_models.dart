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

class PromoterProfileResponse {
  final bool success;
  final String message;
  final PromoterProfileData data;

  PromoterProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PromoterProfileResponse.fromJson(Map<String, dynamic> j) {
    return PromoterProfileResponse(
      success: j['success'] == true,
      message: (j['message'] ?? '').toString(),
      data: PromoterProfileData.fromJson(j['data'] ?? {}),
    );
  }

  static PromoterProfileResponse fromRaw(String raw) =>
      PromoterProfileResponse.fromJson(json.decode(raw));
}

class PromoterProfileData {
  final Profile profile;
  final int countAccount;
  final List<Exhibition> exhibitions;

  PromoterProfileData({
    required this.profile,
    required this.countAccount,
    required this.exhibitions,
  });

  factory PromoterProfileData.fromJson(Map<String, dynamic> j) {
    final ex = <Exhibition>[];
    if (j['exhibitions'] is List) {
      for (final e in (j['exhibitions'] as List)) {
        ex.add(Exhibition.fromJson(e));
      }
    }
    return PromoterProfileData(
      profile: Profile.fromJson(j['profile'] ?? {}),
      countAccount: _asInt(j['count_account']),
      exhibitions: ex,
    );
  }
}

class Profile {
  final int id;
  final int cityId;
  final String cityNameAr;
  final String cityNameEn;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String username;
  final String referralCode;
  final String? profilePictureUrl;
  final String? profileImageUrl;

  Profile({
    required this.id,
    required this.cityId,
    required this.cityNameAr,
    required this.cityNameEn,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.referralCode,
    required this.profilePictureUrl,
    required this.profileImageUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> j) {
    return Profile(
      id: _asInt(j['id']),
      cityId: _asInt(j['city_id']),
      cityNameAr: (j['city_name_ar'] ?? '').toString(),
      cityNameEn: (j['city_name_en'] ?? '').toString(),
      userId: _asInt(j['user_id']),
      createdAt: _asDate(j['created_at']),
      updatedAt: _asDate(j['updated_at']),
      username: (j['username'] ?? '').toString(),
      referralCode: (j['referral_code'] ?? '').toString(),
      profilePictureUrl: (j['profile_picture_url'] ?? j['profile_image_url'])?.toString(),
      profileImageUrl: (j['profile_image_url'] ?? j['profile_picture_url'])?.toString(),
    );
  }
}

class Exhibition {
  final int id;
  final String name;
  final DateTime? createdAt;
  final String imageUrl;
  final String address;
  final int adCount;

  Exhibition({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.imageUrl,
    required this.address,
    required this.adCount,
  });

  factory Exhibition.fromJson(Map<String, dynamic> j) {
    return Exhibition(
      id: _asInt(j['id']),
      name: (j['name'] ?? '').toString(),
      createdAt: _asDate(j['created_at']),
      imageUrl: (j['image_url'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      adCount: _asInt(j['ad_count']),
    );
  }
}