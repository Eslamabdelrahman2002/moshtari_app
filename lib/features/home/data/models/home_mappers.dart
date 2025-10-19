// features/home/data/mappers/home_mappers.dart
import '../models/unified_home_item.dart';

class HomeMappers {
  static List<UnifiedHomeItem> fromHomeResponse(Map raw) {
    final json = Map<String, dynamic>.from(raw);
    final data = Map<String, dynamic>.from(json['data'] ?? {});

    final items = <UnifiedHomeItem>[];

    final carAds = (data['car_ads'] as List?) ?? const [];
    for (final j in carAds) {
      items.add(UnifiedHomeItem.fromCarAd(Map<String, dynamic>.from(j)));
    }

    final carPartsAds = (data['car_parts_ads'] as List?) ?? const [];
    for (final j in carPartsAds) {
      items.add(UnifiedHomeItem.fromCarPartAd(Map<String, dynamic>.from(j)));
    }

    final realEstateAds = (data['real_estate_ads'] as List?) ?? const [];
    for (final j in realEstateAds) {
      items.add(UnifiedHomeItem.fromRealEstateAd(Map<String, dynamic>.from(j)));
    }

    return items;
  }
}