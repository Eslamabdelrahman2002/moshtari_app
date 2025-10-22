// features/home/data/mappers/home_mappers.dart
import '../models/unified_home_item.dart';

class HomeMappers {
  static String _resolveSourceByCategoryId(int? catId, String defaultSource) {
    switch (catId) {
      case 1:
        return 'car_ads';
      case 2:
        return 'real_estate_ads';
      case 3:
        return 'car_parts_ads';
      default:
        return defaultSource;
    }
  }

  static UnifiedHomeItem _itemFromSection(
      Map raw,
      String defaultSource,
      ) {
    final j = Map<String, dynamic>.from(raw);
    final int? catId = j['category_id'] is int ? j['category_id'] as int : int.tryParse('${j['category_id'] ?? ''}');
    final source = _resolveSourceByCategoryId(catId, defaultSource);

    return UnifiedHomeItem(
      id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      title: (j['title'] ?? '').toString(),
      price: j['price'] is num ? j['price'] as num : num.tryParse('${j['price'] ?? ''}'),
      imageUrls: List<String>.from(j['image_urls'] ?? const []),
      categoryId: catId,
      source: source,
    );
  }

  static List<UnifiedHomeItem> fromHomeResponse(Map raw) {
    final json = Map<String, dynamic>.from(raw);
    final data = Map<String, dynamic>.from(json['data'] ?? {});

    final items = <UnifiedHomeItem>[];

    final carAds = (data['car_ads'] as List?) ?? const [];
    for (final e in carAds) {
      items.add(_itemFromSection(e as Map, 'car_ads'));
    }

    final carPartsAds = (data['car_parts_ads'] as List?) ?? const [];
    for (final e in carPartsAds) {
      items.add(_itemFromSection(e as Map, 'car_parts_ads'));
    }

    final realEstateAds = (data['real_estate_ads'] as List?) ?? const [];
    for (final e in realEstateAds) {
      items.add(_itemFromSection(e as Map, 'real_estate_ads'));
    }

    return items;
  }
}