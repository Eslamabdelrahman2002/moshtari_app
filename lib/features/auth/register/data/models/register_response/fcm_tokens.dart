class FcmTokens {
  String? ios;

  FcmTokens({this.ios});

  factory FcmTokens.fromJson(Map<String, dynamic> json) => FcmTokens(
        ios: json['ios'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'ios': ios,
      };
}
