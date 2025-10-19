// lib/features/car_ads/utils/car_mappers.dart
class CarMappers {
  static String condition(String ar) {
    switch (ar) {
      case 'جديد': return 'new';
      case 'مستعمل': return 'used';
      case 'تالف': return 'damaged';
      default: return 'used';
    }
  }

  static String saleType(String ar) {
    switch (ar) {
      case 'تقسيط': return 'installment';
      case 'كاش': return 'cash';
      default: return 'cash';
    }
  }

  static String warranty(String ar) {
    switch (ar) {
      case 'تحت الضمان': return 'under_warranty';
      case 'خارج الضمان': return 'out_of_warranty';
      default: return 'out_of_warranty';
    }
  }

  static String transmission(String ar) {
    switch (ar) {
      case 'قير عادي': return 'manual';
      case 'اوتوماتيك': return 'automatic';
      default: return 'automatic';
    }
  }

  static String fuel(String ar) {
    switch (ar) {
      case 'بنزين': return 'gasoline';
      case 'ديزل': return 'diesel';
      case 'كهربا': return 'electric';
      case 'هايبرد': return 'hybrid';
      default: return 'gasoline';
    }
  }

  static String driveType(String ar) {
    switch (ar) {
      case 'أمامي': return 'front_wheel';
      case 'خلفي': return 'rear_wheel';
      case 'رباعي': return 'all_wheel';
      default: return 'front_wheel';
    }
  }

  static String doors(String ar) {
    switch (ar) {
      case 'بابين': return 'two_door';
      case '4 ابواب': return 'four_door';
      default: return 'other';
    }
  }

  static String vehicleType(String ar) {
    switch (ar) {
      case 'سيدان': return 'sedan';
      case 'دفع رباعي': return 'suv';
      case 'هاتشباك': return 'hatchback';
      default: return 'sedan';
    }
  }

  static String priceType(String ar) {
    switch (ar) {
      case 'سعر محدد': return 'fixed';
      case 'علي السوم': return 'negotiable';
      case 'مزاد': return 'auction';
      default: return 'fixed';
    }
  }
}