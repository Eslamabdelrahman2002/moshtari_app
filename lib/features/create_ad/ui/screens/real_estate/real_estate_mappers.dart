// lib/features/real_estate_ads/utils/real_estate_mappers.dart
class RealEstateMappers {
  static String priceType(String ar) {
    switch (ar) {
      case 'سعر محدد': return 'fixed';
      case 'علي السوم': return 'negotiable';
      case 'مزاد': return 'auction';
      default: return 'fixed';
    }
  }

  static String purpose(bool isForSell) => isForSell ? 'sell' : 'rent';

  static String buildingAge(String ar) {
    switch (ar) {
      case 'جديد': return 'new';
      case 'مستعمل': return 'used';
      case 'قديم': return 'old';
      default: return 'used';
    }
  }

  static String facade(String ar) {
    switch (ar) {
      case 'شمال': return 'north';
      case 'جنوب': return 'south';
      case 'شرق': return 'east';
      case 'غرب': return 'west';
      default: return 'north';
    }
  }

  static String type(String ar) {
    switch (ar) {
      case 'فيلا': return 'villa';
      case 'شقة': return 'apartment';
      case 'أرض': return 'land';
      case 'محل': return 'store';
      default: return 'apartment';
    }
  }
}