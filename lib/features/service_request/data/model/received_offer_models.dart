import 'dart:convert';

// Helpers
int _asInt(v) => v is int ? v : int.tryParse('$v') ?? 0;
bool _asBool(v) => v == true || v?.toString().toLowerCase() == 'true';

class ReceivedOffer {
  final int offerId;
  final String price;           // as string per API
  final String status;          // pending | accepted | rejected
  final DateTime? createdAt;
  final String serviceType;     // dyna | flatbed | tanker
  final String requestStatus;   // in_progress | completed | pending | rejected
  final int providerId;
  final String fullName;
  final String? personalImage;
  final bool isVerified;

  ReceivedOffer({
    required this.offerId,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.serviceType,
    required this.requestStatus,
    required this.providerId,
    required this.fullName,
    required this.personalImage,
    this.isVerified = false,
  });

  factory ReceivedOffer.fromJson(Map<String, dynamic> j) => ReceivedOffer(
    offerId: _asInt(j['offer_id']),
    price: (j['price'] ?? '').toString(),
    status: (j['status'] ?? '').toString(),
    createdAt: j['created_at'] != null ? DateTime.tryParse('${j['created_at']}') : null,
    serviceType: (j['service_type'] ?? '').toString(),
    requestStatus: (j['request_status'] ?? '').toString(),
    providerId: _asInt(j['provider_id']),
    fullName: (j['full_name'] ?? '').toString(),
    personalImage: (j['personal_image'] ?? '').toString().isEmpty ? null : (j['personal_image'] as String),
    isVerified: _asBool(j['is_verified'] ?? j['verified'] ?? false),
  );
}

class MyReceivedOffersResponse {
  final bool success;
  final String? message;
  final List<ReceivedOffer> offers;

  MyReceivedOffersResponse({
    required this.success,
    required this.offers,
    this.message,
  });

  factory MyReceivedOffersResponse.fromJson(Map<String, dynamic> j) {
    final list = <ReceivedOffer>[];
    final raw = j['data'];
    if (raw is List) {
      for (final e in raw) list.add(ReceivedOffer.fromJson(e));
    } else if (raw is Map<String, dynamic>) {
      list.add(ReceivedOffer.fromJson(raw));
    }
    return MyReceivedOffersResponse(
      success: j['success'] == true,
      message: (j['message'] ?? '').toString(),
      offers: list,
    );
  }

  static MyReceivedOffersResponse fromRaw(String raw) =>
      MyReceivedOffersResponse.fromJson(json.decode(raw));
}