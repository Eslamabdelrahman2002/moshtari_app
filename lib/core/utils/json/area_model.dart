class Area {
  final int areaId;
  final String areaName;
  final String areaNameEn;
  final String areaNameAr;
  final int cityId;
  final String cityName;
  final String cityNameEn;
  final String cityNameAr;
  final String? polygonCenter;
  final String areaSlug;

  Area({
    required this.areaId,
    required this.areaName,
    required this.areaNameEn,
    required this.areaNameAr,
    required this.cityId,
    required this.cityName,
    required this.cityNameEn,
    required this.cityNameAr,
    this.polygonCenter,
    required this.areaSlug,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      areaId: json['area_id'],
      areaName: json['area_name'],
      areaNameEn: json['area_name_en'],
      areaNameAr: json['area_name_ar'],
      cityId: json['city_id'],
      cityName: json['city_name'],
      cityNameEn: json['city_name_en'],
      cityNameAr: json['city_name_ar'],
      polygonCenter: json['polygon_center'],
      areaSlug: json['area_slug'],
    );
  }
}
