// lib/features/product_details/data/model/received_offer.dart
int _asInt(v) => v is int ? v : int.tryParse('$v') ?? 0;
double _asDouble(v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;

class ReceivedOffer {
  final int offerId;
  final double price;
  final String status;         // pending | accepted | cancelled | ...
  final DateTime? createdAt;
  final String serviceType;
  final String requestStatus;  // حالة الطلب المرتبط (completed مثلاً)
  final int providerId;
  final String fullName;
  final String? personalImage;

  ReceivedOffer({
    required this.offerId,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.serviceType,
    required this.requestStatus,
    required this.providerId,
    required this.fullName,
    this.personalImage,
  });

  factory ReceivedOffer.fromJson(Map<String, dynamic> j) => ReceivedOffer(
    offerId: _asInt(j['offer_id']),
    price: _asDouble(j['price']),
    status: (j['status'] ?? '').toString(),
    createdAt: j['created_at'] != null
        ? DateTime.tryParse(j['created_at'].toString())
        : null,
    serviceType: (j['service_type'] ?? '').toString(),
    requestStatus: (j['request_status'] ?? '').toString(),
    providerId: _asInt(j['provider_id']),
    fullName: (j['full_name'] ?? '').toString(),
    personalImage: (j['personal_image'] ?? '').toString().isEmpty
        ? null
        : (j['personal_image'] as String),
  );
}