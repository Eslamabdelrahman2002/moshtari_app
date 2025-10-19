import 'bargains_model.dart';
import 'car_model.dart';

class AuctionsModel {
  final int? id;
  final String? title;
  final String? location;
  // ✨ CHANGED price to String? to match your UI code that expects a String
  final String? price;
  final DateTime? createdAt;
  final CarModel? car;
  // ✨ ADDED missing properties
  final String? description;
  final List<BargainModel>? bargain;


  AuctionsModel({
    this.id,
    this.title,
    this.location,
    this.price,
    this.createdAt,
    this.car,
    this.description,
    this.bargain,
  });

  factory AuctionsModel.fromJson(Map<String, dynamic> json) {
    var bargainList = json['bargain'] as List?;
    List<BargainModel>? bargains =
    bargainList?.map((b) => BargainModel.fromJson(b)).toList();

    return AuctionsModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      title: json['title'],
      location: json['location'],
      // ✨ PARSE price as a String
      price: json['price']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      car: json['car'] != null ? CarModel.fromJson(json['car']) : null,
      // ✨ PARSE missing properties
      description: json['description'],
      bargain: bargains,
    );
  }
}