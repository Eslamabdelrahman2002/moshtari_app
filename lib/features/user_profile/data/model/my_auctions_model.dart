  class MyAuctionModel {
    final int id;
    final int userId;
    final String title;
    final String description;
    final String startingPrice;
    final List<String> imageUrls;
    final String createdAt;
    final String ownerName;
    final String ownerPicture;

    MyAuctionModel({
      required this.id,
      required this.userId,
      required this.title,
      required this.description,
      required this.startingPrice,
      required this.imageUrls,
      required this.createdAt,
      required this.ownerName,
      required this.ownerPicture,
    });

    factory MyAuctionModel.fromJson(Map<String, dynamic> json) {
      return MyAuctionModel(
        id: json['id'],
        userId: json['user_id'],
        title: json['title'],
        description: json['description'],
        startingPrice: json['starting_price'] ?? json['price'] ?? '',
        imageUrls: List<String>.from(json['image_urls'] ?? []),
        createdAt: json['created_at'],
        ownerName: json['owner_name'],
        ownerPicture: json['owner_picture'],
      );
    }
  }
