// file: features/other_ads/data/models/offer_model.dart

class OfferModel {
  final int id;
  final int adId;
  final int userId;
  final String userName;
  final String? userPicture;
  final double? offerPrice; // استخدم double لدعم الأرقام العشرية إن وجدت
  final String? offerComment;
  final DateTime createdAt;

  OfferModel({
    required this.id,
    required this.adId,
    required this.userId,
    required this.userName,
    this.userPicture,
    this.offerPrice,
    this.offerComment,
    required this.createdAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: (json['offer_id'] as num?)?.toInt() ?? 0,
      adId: (json['ad_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      userName: json['user_name']?.toString() ?? '',
      userPicture: json['user_picture']?.toString(),
      offerPrice: (json['offer_price'] as num?)?.toDouble(), // التحويل إلى double
      offerComment: json['offer_comment']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}