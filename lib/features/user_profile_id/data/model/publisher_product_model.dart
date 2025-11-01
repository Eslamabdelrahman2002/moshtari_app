class PublisherProductModel {
  final int id;
  final String title;
  final String description;
  final String priceText;
  final String createdAt;
  final String? imageUrl;
  final String categoryLabel;
  final bool isAuction;
  final int categoryId;
  final String? auctionType;

  PublisherProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceText,
    required this.createdAt,
    this.imageUrl,
    required this.categoryLabel,
    required this.isAuction,
    required this.categoryId,
    this.auctionType,
  });
}