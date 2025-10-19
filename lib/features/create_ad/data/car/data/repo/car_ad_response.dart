// lib/features/car_ads/data/models/car_ad_response.dart
class CarAdResponse {
  final bool success;
  final String message;
  final int? id;

  CarAdResponse({
    required this.success,
    required this.message,
    this.id,
  });

  factory CarAdResponse.fromJson(Map<String, dynamic> json) {
    return CarAdResponse(
      success: json['success'] == true || json['status'] == 'success',
      message: (json['message'] ?? '').toString(),
      id: json['id'] is int ? json['id'] as int : (json['data']?['id'] as int?),
    );
  }
}