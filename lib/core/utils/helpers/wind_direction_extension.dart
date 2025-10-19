extension DirectionExtension on int {
  String toArabicWindDirection() {
    switch (this) {
      case 1:
        return 'شمال';
      case 2:
        return 'شمال شرقي';
      case 3:
        return 'شرق';
      case 4:
        return 'جنوب شرقي';
      case 5:
        return 'جنوب';
      case 6:
        return 'جنوب غربي';
      case 7:
        return 'غرب';
      case 8:
        return 'شمال غربي';
      default:
        return 'اتجاه غير معروف';
    }
  }
}
