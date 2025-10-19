import '../../../../auth/login/data/models/user_model.dart';

class BargainModel {
  final int? id;
  final int? price;
  // ✨ ADD THE MISSING PROPERTIES
  final String? comment;
  final DateTime? createdAt;
  final UserModel? user;

  BargainModel({
    this.id,
    this.price,
    this.comment,
    this.createdAt,
    this.user
  });

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory BargainModel.fromJson(Map<String, dynamic> json) {
    return BargainModel(
      id: _parseToInt(json['id']),
      price: _parseToInt(json['price']),
      // ✨ PARSE THE NEW PROPERTIES FROM JSON
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}