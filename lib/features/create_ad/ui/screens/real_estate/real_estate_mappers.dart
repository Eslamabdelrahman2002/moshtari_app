// lib/features/create_ad/ui/screens/real_estate/real_estate_mappers.dart
class RealEstateMappers {
  // priceType واجهة -> API
  static String priceType(String label) {
    switch (label.trim()) {
      case 'سعر محدد':
        return 'fixed';
      case 'علي السوم':
        return 'negotiable';
      case 'مزاد':
        return 'auction';
      default:
        return 'fixed';
    }
  }

  // priceType API -> API (normalize)
  static String priceTypeFromApi(String? api) {
    switch (api) {
      case 'fixed':
      case 'negotiable':
      case 'auction':
        return api!;
      default:
        return 'fixed';
    }
  }

  // نوع العقار واجهة -> API
  static String? type(String label) {
    switch (label.trim()) {
      case 'شقة':
        return 'apartment';
      case 'فيلا':
        return 'villa';
      case 'أرض سكنية':
        return 'residential_land';
      case 'أراضي':
        return 'lands';
      case 'شقق و غرف':
        return 'apartments_rooms';
      case 'فلل وقصور':
        return 'villas_palaces';
      case 'دور':
        return 'floor';
      case 'عمائر و أبراج':
        return 'buildings_towers';
      case 'شاليهات و استراحات':
        return 'chalets_resthouses';
      default:
        return null;
    }
  }

  // نوع العقار API -> واجهة
  static String typeToLabel(String api) {
    switch (api) {
      case 'apartment':
        return 'شقة';
      case 'villa':
        return 'فيلا';
      case 'residential_land':
        return 'أرض سكنية';
      case 'lands':
        return 'أراضي';
      case 'apartments_rooms':
        return 'شقق و غرف';
      case 'villas_palaces':
        return 'فلل وقصور';
      case 'floor':
        return 'دور';
      case 'buildings_towers':
        return 'عمائر و أبراج';
      case 'chalets_resthouses':
        return 'شاليهات و استراحات';
      default:
        return 'شقة';
    }
  }

  // لو جاك من API قيمة النوع
  static String? typeFromApi(String? api) => api;

  // الغرض
  static String purpose(bool isForSell) => isForSell ? 'sell' : 'rent';
  static bool purposeToIsForSell(String? p) => p == 'sell';

  // الواجهة
  static String facade(String label) {
    switch (label.trim()) {
      case 'شمال':
        return 'north';
      case 'جنوب':
        return 'south';
      case 'شرق':
        return 'east';
      case 'غرب':
        return 'west';
      default:
        return 'north';
    }
  }

  static String facadeToLabel(String api) {
    switch (api) {
      case 'north':
        return 'شمال';
      case 'south':
        return 'جنوب';
      case 'east':
        return 'شرق';
      case 'west':
        return 'غرب';
      default:
        return 'شمال';
    }
  }

  // عمر المبنى
  static String buildingAge(String label) {
    switch (label.trim()) {
      case 'جديد':
        return 'new';
      case 'مستعمل':
        return 'used';
      case 'قديم':
        return 'old';
      default:
        return 'new';
    }
  }

  static String buildingAgeToLabel(String api) {
    switch (api) {
      case 'new':
        return 'جديد';
      case 'used':
        return 'مستعمل';
      case 'old':
        return 'قديم';
      default:
        return 'جديد';
    }
  }
}