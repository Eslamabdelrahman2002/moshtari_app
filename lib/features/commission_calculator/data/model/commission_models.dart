import 'dart:convert';

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse('$v') ?? 0.0;
}
int _asInt(dynamic v) {
  if (v is int) return v;
  return int.tryParse('$v') ?? 0;
}

class CommissionItem {
  final int id;
  final String category; // cars, real_estate, spare_cars, other
  final double percentage;

  CommissionItem({
    required this.id,
    required this.category,
    required this.percentage,
  });

  factory CommissionItem.fromJson(Map<String, dynamic> j) => CommissionItem(
    id: _asInt(j['id']),
    category: (j['category'] ?? '').toString(),
    percentage: _asDouble(j['percentage']),
  );
}

class CommissionResponse {
  final bool success;
  final String message;
  final List<CommissionItem> data;

  CommissionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommissionResponse.fromJson(Map<String, dynamic> j) {
    final list = <CommissionItem>[];
    if (j['data'] is List) {
      for (final e in (j['data'] as List)) {
        list.add(CommissionItem.fromJson(e));
      }
    }
    return CommissionResponse(
      success: j['success'] == true,
      message: (j['message'] ?? '').toString(),
      data: list,
    );
  }

  static CommissionResponse fromRaw(String raw) =>
      CommissionResponse.fromJson(json.decode(raw));
}