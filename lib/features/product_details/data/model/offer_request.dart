class OfferRequest {
  final int adId;
  final num amount;
  final String? message;

  OfferRequest({
    required this.adId,
    required this.amount,
    this.message,
  });

  Map<String, dynamic> toMap() => {
    'ad_id': adId,
    'amount': amount,
    if (message != null && message!.trim().isNotEmpty) 'message': message,
  };
}