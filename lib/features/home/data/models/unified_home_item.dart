// features/home/data/models/unified_home_item.dart
class UnifiedHomeItem {
  final int id;
  final String title;
  final num? price;
  final List<String> imageUrls;
  final int? categoryId; // 1 سيارات، 2 عقارات، 3 قطع غيار
  final String source;   // car_ads | real_estate_ads | car_parts_ads

  const UnifiedHomeItem({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.source,
    this.price,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'image_urls': imageUrls,
    'category_id': categoryId,
    'source': source,
  };
}