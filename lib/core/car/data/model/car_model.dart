class CarModel {
  final int id;
  final int carTypeId;
  final String nameAr;
  final String nameEn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CarModel({
    required this.id,
    required this.carTypeId,
    required this.nameAr,
    required this.nameEn,
    this.createdAt,
    this.updatedAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      carTypeId: json['car_type_id'] is String ? int.tryParse(json['car_type_id']) ?? 0 : (json['car_type_id'] ?? 0),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;
}