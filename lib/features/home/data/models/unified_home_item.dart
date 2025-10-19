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

  // منشئات مساعدة لكل قسم
  factory UnifiedHomeItem.fromCarAd(Map<String, dynamic> j) {
    return UnifiedHomeItem(
      id: j['id'] ?? 0,
      title: (j['title'] ?? '').toString(),
      price: j['price'] is num ? j['price'] : num.tryParse('${j['price']}'),
      imageUrls: List<String>.from(j['image_urls'] ?? const []),
      categoryId: j['category_id'] is int ? j['category_id'] : 1,
      source: 'car_ads',
    );
  }

  factory UnifiedHomeItem.fromCarPartAd(Map<String, dynamic> j) {
    return UnifiedHomeItem(
      id: j['id'] ?? 0,
      title: (j['title'] ?? '').toString(),
      price: j['price'] is num ? j['price'] : num.tryParse('${j['price']}'),
      imageUrls: List<String>.from(j['image_urls'] ?? const []),
      categoryId: j['category_id'] is int ? j['category_id'] : 3,
      source: 'car_parts_ads',
    );
  }

  factory UnifiedHomeItem.fromRealEstateAd(Map<String, dynamic> j) {
    return UnifiedHomeItem(
      id: j['id'] ?? 0,
      title: (j['title'] ?? '').toString(),
      price: j['price'] is num ? j['price'] : num.tryParse('${j['price']}'),
      imageUrls: List<String>.from(j['image_urls'] ?? const []),
      categoryId: j['category_id'] is int ? j['category_id'] : 2,
      source: 'real_estate_ads',
    );
  }
}