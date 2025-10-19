class AdReviewResponse {
  final bool success;
  final String message;
  final int? reviewId;
  final int? commentId;

  AdReviewResponse({
    required this.success,
    required this.message,
    this.reviewId,
    this.commentId,
  });

  factory AdReviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final review = data?['review'] as Map<String, dynamic>?;
    final comment = data?['comment'] as Map<String, dynamic>?;

    return AdReviewResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      reviewId: review?['review_id'] as int?,
      commentId: comment?['comment_id'] as int?,
    );
  }
}