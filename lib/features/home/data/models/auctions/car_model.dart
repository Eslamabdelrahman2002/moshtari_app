class CarModel {
  final int? id;
  final String? status;
  final List<String>? images;
  // ✨ ADDED missing car properties
  final String? kilometers;
  final String? gearType;
  final int? cylinderCount;
  final String? color;
  final String? fuelType;
  final String? wheelDriveType;


  CarModel({
    this.id,
    this.status,
    this.images,
    this.kilometers,
    this.gearType,
    this.cylinderCount,
    this.color,
    this.fuelType,
    this.wheelDriveType,
  });

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: _parseToInt(json['id']),
      status: json['status'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      // ✨ PARSE missing car properties from JSON
      kilometers: json['kilometers']?.toString(),
      gearType: json['gear_type'],
      cylinderCount: _parseToInt(json['cylinder_count']),
      color: json['color'],
      fuelType: json['fuel_type'],
      wheelDriveType: json['wheel_drive_type'],
    );
  }
}
