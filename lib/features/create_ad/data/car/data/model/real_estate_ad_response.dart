class RealEstateAdResponse {
  final bool success;
  final String message;
  final int? id;

  RealEstateAdResponse({
    required this.success,
    required this.message,
    this.id,
  });

  factory RealEstateAdResponse.fromJson(Map<String, dynamic> json) {
    return RealEstateAdResponse(
      success: json['success'] == true || json['status'] == 'success',
      message: (json['message'] ?? '').toString(),
      id: json['id'] is int ? json['id'] as int : (json['data']?['id'] as int?),
    );
  }
}