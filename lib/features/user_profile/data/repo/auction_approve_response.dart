class AuctionApproveResponse {
  final bool success;
  final String message;

  AuctionApproveResponse({
    required this.success,
    required this.message,
  });

  factory AuctionApproveResponse.fromJson(Map<String, dynamic> j) {
    return AuctionApproveResponse(
      success: j['success'] == true || j['status'] == true,
      message: (j['message'] ?? j['msg'] ?? '').toString(),
    );
  }
}