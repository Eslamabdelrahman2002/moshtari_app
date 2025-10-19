// lib/features/product_details/data/models/place_bid_result.dart
class PlaceBidResult {
  final bool success;
  final String? message;
  final num? maxBid;

  PlaceBidResult({required this.success, this.message, this.maxBid});

  factory PlaceBidResult.fromAck(dynamic ack) {
    try {
      if (ack is Map) {
        final map = Map<String, dynamic>.from(ack);
        final bool success =
            (map['success'] == true) ||
                (map['status']?.toString().toLowerCase() == 'success');
        final String? message = map['message']?.toString();

        num? parsedMax;
        final data = map['data'];
        if (data is Map) {
          final mb = data['maxBid'] ?? data['max_bid'];
          if (mb is num) parsedMax = mb;
          if (mb is String) parsedMax = num.tryParse(mb);
        }

        return PlaceBidResult(success: success, message: message, maxBid: parsedMax);
      }
      return PlaceBidResult(success: false, message: 'Bad Ack format');
    } catch (_) {
      return PlaceBidResult(success: false, message: 'Ack parsing error');
    }
  }
}