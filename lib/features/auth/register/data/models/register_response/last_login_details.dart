import 'platform_details.dart';

class LastLoginDetails {
  DateTime? lastLoginAt;
  String? lastLoginDevice;
  PlatformDetails? platformDetails;

  LastLoginDetails({
    this.lastLoginAt,
    this.lastLoginDevice,
    this.platformDetails,
  });

  factory LastLoginDetails.fromJson(Map<String, dynamic> json) {
    return LastLoginDetails(
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      lastLoginDevice: json['lastLoginDevice'] as String?,
      platformDetails: json['platformDetails'] == null
          ? null
          : PlatformDetails.fromJson(
              json['platformDetails'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'lastLoginDevice': lastLoginDevice,
        'platformDetails': platformDetails?.toJson(),
      };
}
