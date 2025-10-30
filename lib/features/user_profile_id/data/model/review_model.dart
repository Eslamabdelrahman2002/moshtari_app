class ReviewModel {
  final int reviewId;
  final String? comment;
  final double? rating;
  final String? reviewerName;
  final String? reviewerImage;
  final String createdAt;

  ReviewModel({
    required this.reviewId,
    required this.comment,
    this.rating,
    this.reviewerName,
    this.reviewerImage,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    return ReviewModel(
      reviewId: json['review_id'] as int,
      comment: json['comment'] as String?,
      rating: rawRating != null ? (rawRating is num ? rawRating.toDouble() : double.tryParse(rawRating.toString())) : null,
      reviewerName: json['reviewer_name'] as String?,
      reviewerImage: json['reviewer_image'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}