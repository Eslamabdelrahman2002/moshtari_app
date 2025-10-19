class NotificationManager {
  bool? android;
  bool? ios;
  bool? desktop;

  NotificationManager({this.android, this.ios, this.desktop});

  factory NotificationManager.fromJson(Map<String, dynamic> json) {
    return NotificationManager(
      android: json['android'] as bool?,
      ios: json['ios'] as bool?,
      desktop: json['desktop'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'android': android,
        'ios': ios,
        'desktop': desktop,
      };
}
