// lib/features/offers/data/model/offer_details.dart
class OfferDetails {
  final int id;
  final int? adId;
  final num amount;
  final String? message;
  final int? userId;
  final String? username;
  final String? createdAt;

  OfferDetails({
    required this.id,
    required this.amount,
    this.adId,
    this.message,
    this.userId,
    this.username,
    this.createdAt,
  });

  factory OfferDetails.fromJson(Map<String, dynamic> json) {
    return OfferDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
      adId: (json['ad_id'] as num?)?.toInt(),
      amount: json['amount'] is num
          ? json['amount']
          : num.tryParse(json['amount']?.toString() ?? '') ?? 0,
      message: json['message']?.toString(),
      userId: (json['user_id'] as num?)?.toInt() ?? (json['user'] is Map ? (json['user']['id'] as num?)?.toInt() : null),
      username: json['username']?.toString() ?? (json['user'] is Map ? json['user']['username']?.toString() : null),
      createdAt: json['created_at']?.toString(),
    );
  }
}