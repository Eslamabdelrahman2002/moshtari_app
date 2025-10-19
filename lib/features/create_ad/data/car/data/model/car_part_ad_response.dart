class CarPartAdResponse {
  final bool success;
  final String message;
  final int? id;

  CarPartAdResponse({
    required this.success,
    required this.message,
    this.id,
  });

  factory CarPartAdResponse.fromJson(Map<String, dynamic> json) {
    return CarPartAdResponse(
      success: json['success'] == true || json['status'] == 'success',
      message: (json['message'] ?? '').toString(),
      id: json['id'] is int ? json['id'] as int : (json['data']?['id'] as int?),
    );
  }
}