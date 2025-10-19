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
  final String ownerPicture;

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
    required this.ownerPicture,
  });

  factory MyAdsModel.fromJson(Map<String, dynamic> json) {
    return MyAdsModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      categoryId: json['category_id'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      createdAt: json['created_at'],
      ownerName: json['owner_name'],
      ownerPicture: json['owner_picture'],
    );
  }
}
