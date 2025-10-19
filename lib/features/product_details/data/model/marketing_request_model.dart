class MarketingRequestModel {
  final int id;
  final int adId;
  final int requesterId;
  final int ownerId;
  final String status;
  final String message;
  final String createdAt;
  final String updatedAt;

  MarketingRequestModel({
    required this.id,
    required this.adId,
    required this.requesterId,
    required this.ownerId,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingRequestModel.fromJson(Map<String, dynamic> json) {
    return MarketingRequestModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      adId: (json['ad_id'] as num?)?.toInt() ?? 0,
      requesterId: (json['requester_id'] as num?)?.toInt() ?? 0,
      ownerId: (json['owner_id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}