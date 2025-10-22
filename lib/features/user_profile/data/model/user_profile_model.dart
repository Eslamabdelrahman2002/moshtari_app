class ProviderInfo {
  final int providerId;
  final String? status;
  final int? cityId;
  final String? cityNameAr;
  final String? cityNameEn;
  final String? serviceType;

  const ProviderInfo({
    required this.providerId,
    this.status,
    this.cityId,
    this.cityNameAr,
    this.cityNameEn,
    this.serviceType,
  });

  static int? _asIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory ProviderInfo.fromJson(Map<String, dynamic> j) => ProviderInfo(
    providerId: _asIntOrNull(j['provider_id']) ?? 0,
    status: j['status']?.toString(),
    cityId: _asIntOrNull(j['city_id']),
    cityNameAr: j['city_name_ar']?.toString(),
    cityNameEn: j['city_name_en']?.toString(),
    serviceType: j['service_type']?.toString(),
  );
}

class UserProfileModel {
  final int userId;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final bool isVerified;
  final String? referralCode;
  final ProviderInfo? provider;
  final dynamic promoter; // حسب الـ API قد يكون null أو كائن لاحقًا

  const UserProfileModel({
    required this.userId,
    this.username,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.isVerified = false,
    this.referralCode,
    this.provider,
    this.promoter,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return false;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
    userId: _asInt(json['user_id']),
    username: json['username']?.toString(),
    email: json['email']?.toString(),
    phoneNumber: json['phone_number']?.toString(),
    profilePictureUrl: json['profile_picture_url']?.toString(),
    isVerified: _asBool(json['is_verified']),
    referralCode: json['referral_code']?.toString(),
    provider: json['provider'] is Map<String, dynamic>
        ? ProviderInfo.fromJson(json['provider'])
        : null,
    promoter: json['promoter'],
  );
}