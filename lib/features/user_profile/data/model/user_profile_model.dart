class ProviderInfo {
  final int providerId;
  final String? status;
  final int? cityId;
  final String? cityNameAr;
  final String? cityNameEn;
  final String? serviceType;

  ProviderInfo({
    required this.providerId,
    this.status,
    this.cityId,
    this.cityNameAr,
    this.cityNameEn,
    this.serviceType,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> j) {
    int _asInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return ProviderInfo(
      providerId: _asInt(j['provider_id']),
      status: (j['status'] ?? '').toString(),
      cityId: _asInt(j['city_id']),
      cityNameAr: (j['city_name_ar'] ?? '').toString(),
      cityNameEn: (j['city_name_en'] ?? '').toString(),
      serviceType: (j['service_type'] ?? '').toString(),
    );
  }
}

class UserProfileModel {
  final int userId;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final bool? isVerified;
  final String? referral_code;

  // NEW
  final ProviderInfo? provider;

  UserProfileModel({
    required this.userId,
    this.username,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.isVerified,
    this.referral_code,
    this.provider, // NEW
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse('${json['user_id']}') ?? 0,
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profilePictureUrl: json['profile_picture_url'],
      isVerified: json['is_verified'] ?? false,
      referral_code: json['referral_code'],
      provider: json['provider'] is Map<String, dynamic>
          ? ProviderInfo.fromJson(json['provider'])
          : null,
    );
  }
}