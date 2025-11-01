import 'package:mushtary/features/user_profile_id/data/model/publisher_product_model.dart';

class MyAuctionModel {
  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final String type;        // single | multiple
  final String createdAt;
  final String typeAuctions;// real_estate | car | ...
  final String startingPrice;

  const MyAuctionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.type,
    required this.createdAt,
    required this.typeAuctions,
    required this.startingPrice,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _asStr(dynamic v) => v?.toString() ?? '';

  factory MyAuctionModel.fromJson(Map<String, dynamic> json) => MyAuctionModel(
    id: _asInt(json['id']),
    title: _asStr(json['title']),
    description: _asStr(json['description']),
    thumbnail: _asStr(json['thumbnail']),
    type: _asStr(json['type']),
    createdAt: _asStr(json['created_at']),
    typeAuctions: _asStr(json['type_auctions']),
    startingPrice: _asStr(json['starting_price'] ?? json['price']),
  );

  /// تحويل نموذج المزاد إلى نموذج المنتج العام للناشر
  PublisherProductModel toPublisherProduct() {
    String categoryLabel;
    int categoryId = 0; // قيمة افتراضية، يمكن تعديلها حسب الحاجة

    switch (typeAuctions.toLowerCase()) {
      case 'car':
        categoryLabel = 'مزاد سيارة';
        categoryId = 1; // افتراضي بناءً على MyAdsModel
        break;
      case 'real_estate':
        categoryLabel = 'مزاد عقار';
        categoryId = 3; // افتراضي بناءً على MyAdsModel
        break;
      case 'spare_parts': // افتراضي لقطع الغيار إذا كان موجوداً
        categoryLabel = 'مزاد قطع غيار';
        categoryId = 2;
        break;
      default:
        categoryLabel = 'مزاد';
        categoryId = 0;
    }

    return PublisherProductModel(
      id: id,
      title: title,
      description: description,
      priceText: startingPrice,
      createdAt: createdAt,
      imageUrl: thumbnail.isNotEmpty ? thumbnail : null,
      categoryLabel: categoryLabel,
      isAuction: true,
      categoryId: categoryId,
      auctionType: type, // single | multiple
    );
  }
}