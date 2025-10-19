import 'package:json_annotation/json_annotation.dart';

part 'banners_model.g.dart';

@JsonSerializable()
class BannersModel {
  String? id;
  String? url;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;

  BannersModel({
    this.id,
    this.url,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory BannersModel.fromJson(Map<String, dynamic> json) =>
      _$BannersModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannersModelToJson(this);
}
