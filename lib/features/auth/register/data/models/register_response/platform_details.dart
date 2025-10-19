class PlatformDetails {
  String? deviceName;
  String? fcmToken;
  String? device;

  PlatformDetails({this.deviceName, this.fcmToken, this.device});

  factory PlatformDetails.fromJson(Map<String, dynamic> json) {
    return PlatformDetails(
      deviceName: json['deviceName'] as String?,
      fcmToken: json['fcmToken'] as String?,
      device: json['device'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'fcmToken': fcmToken,
        'device': device,
      };
}
