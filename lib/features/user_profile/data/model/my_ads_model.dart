class MyAdsModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String price; // يأتي كنص "250.00"
  final int categoryId;
  final List<String> imageUrls;
  final String createdAt;
  final String ownerName;
  final String ownerPicture;

  const MyAdsModel({
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

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _asStr(dynamic v) => v?.toString() ?? '';

  static List<String> _asStrList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }

  factory MyAdsModel.fromJson(Map<String, dynamic> json) => MyAdsModel(
    id: _asInt(json['id']),
    userId: _asInt(json['user_id']),
    title: _asStr(json['title']),
    description: _asStr(json['description']),
    price: _asStr(json['price']),
    categoryId: _asInt(json['category_id']),
    imageUrls: _asStrList(json['image_urls']),
    createdAt: _asStr(json['created_at']),
    ownerName: _asStr(json['owner_name']),
    ownerPicture: _asStr(json['owner_picture']),
  );
}