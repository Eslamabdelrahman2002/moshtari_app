class CarType {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CarType({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory CarType.fromJson(Map<String, dynamic> json) {
    return CarType(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}