import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart';

class MyAdsModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String price;
  final int categoryId;
  final List<String> imageUrls;
  final String createdAt;
  final String ownerName;
  final String? ownerPicture;

  MyAdsModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrls,
    required this.createdAt,
    required this.ownerName,
    this.ownerPicture,
  });

  factory MyAdsModel.fromJson(Map<String, dynamic> json) {
    return MyAdsModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      categoryId: json['category_id'] as int,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['created_at'] as String,
      ownerName: json['owner_name'] as String,
      ownerPicture: json['owner_picture'] as String?,
    );
  }

  PublisherProductModel toPublisherProduct() {
    String categoryLabel;
    switch (categoryId) {
      case 1:
      case 5:
        categoryLabel = 'إعلان سيارة';
        break;
      case 2:
        categoryLabel = 'إعلان قطع غيار';
        break;
      case 3:
        categoryLabel = 'إعلان عقار';
        break;
      case 4:
        categoryLabel = 'إعلان آخر';
        break;
      default:
        categoryLabel = 'إعلان';
    }

    return PublisherProductModel(
      id: id,
      title: title,
      description: description,
      priceText: price,
      createdAt: createdAt,
      imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
      categoryLabel: categoryLabel,
      isAuction: false,
      categoryId: categoryId,
      auctionType: null,
    );
  }
}