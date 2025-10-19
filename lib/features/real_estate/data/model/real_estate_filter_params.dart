class RealEstateFilterParams {
  final String? type;
  final int? cityId;
  final int? regionId;
  final int? minPrice;
  final int? maxPrice;
  final String? sortBy;

  RealEstateFilterParams({
    this.type,
    this.cityId,
    this.regionId,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  // Method to convert filter params to a map for Dio
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'city_id': cityId,
      'region_id': regionId,
      'min_price': minPrice,
      'max_price': maxPrice,
      'sort_by': sortBy,
    }..removeWhere((key, value) => value == null); // Remove null values
  }
}