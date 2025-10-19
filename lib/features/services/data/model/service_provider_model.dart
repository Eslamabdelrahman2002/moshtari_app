class ServiceProviderModel {
  final int id;
  final String fullName;
  final String? phone;
  final int labourId;
  final String labourName;
  final int? cityId;
  final String? cityName;
  final int? regionId;
  final double? latitude;
  final double? longitude;
  final double? averageRating;
  final String? personalImage;

  ServiceProviderModel({
    required this.id,
    required this.fullName,
    required this.labourId,
    required this.labourName,
    this.phone,
    this.cityId,
    this.cityName,
    this.regionId,
    this.latitude,
    this.longitude,
    this.averageRating,
    this.personalImage,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> j) {
    double? _toD(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0; // default to 0.0 if parsing fails
    }

    return ServiceProviderModel(
      id: (j['id'] as int?) ?? 0, // default if null
      fullName: (j['full_name'] ?? 'Unknown').toString(),
      phone: (j['phone'] ?? '').toString(),
      labourId: (j['labour_id'] as int?) ?? 0,
      labourName: (j['labour_name'] ?? '').toString(),
      cityId: j['city_id'] as int?,
      cityName: (j['city_name'] ?? '').toString(),
      regionId: j['region_id'] as int?,
      latitude: _toD(j['latitude']),
      longitude: _toD(j['longitude']),
      averageRating: _toD(j['averageRating']),
      personalImage: (j['personal_image'] ?? '').toString(),
    );
  }
}