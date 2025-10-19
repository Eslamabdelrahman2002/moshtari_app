import 'dart:convert';

int _asInt(v) => v is int ? v : int.tryParse('$v') ?? 0;
double _asDouble(v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;

class ProviderRating {
  final double average;
  final double price;
  final double professionalism;
  final double speed;
  final double quality;
  final double? behavior;

  ProviderRating({
    required this.average,
    required this.price,
    required this.professionalism,
    required this.speed,
    required this.quality,
    this.behavior,
  });

  factory ProviderRating.fromJson(Map<String, dynamic> j) => ProviderRating(
    average: _asDouble(j['average']),
    price: _asDouble(j['price']),
    professionalism: _asDouble(j['professionalism']),
    speed: _asDouble(j['speed']),
    quality: _asDouble(j['quality']),
    behavior: j['behavior'] == null ? null : _asDouble(j['behavior']),
  );
}

class CommentUser {
  final int id;
  final String name;
  final String? personalImage;

  CommentUser({required this.id, required this.name, this.personalImage});

  factory CommentUser.fromJson(Map<String, dynamic> j) => CommentUser(
    id: _asInt(j['id']),
    name: (j['name'] ?? '').toString(),
    personalImage: (j['personal_image'] ?? '').toString().isEmpty ? null : (j['personal_image'] as String),
  );
}

class ProviderComment {
  final int id;
  final String comment;
  final DateTime? createdAt;
  final CommentUser user;

  ProviderComment({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  factory ProviderComment.fromJson(Map<String, dynamic> j) => ProviderComment(
    id: _asInt(j['id']),
    comment: (j['comment'] ?? '').toString(),
    createdAt: j['created_at'] != null ? DateTime.tryParse('${j['created_at']}') : null,
    user: CommentUser.fromJson(j['user'] ?? {}),
  );
}

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
  final String? nationality; // جديد
  final String? description; // جديد
  final List<ProviderComment> comments; // جديد
  final ProviderRating rating; // جديد
  final int reviewsCount; // جديد
  final String? serviceType; // جديد
  final List<String> extraImages; // جديد

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
    this.nationality,
    this.description,
    this.comments = const [],
    required this.rating,
    required this.reviewsCount,
    this.serviceType,
    this.extraImages = const [],
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> j) {
    double? _toD(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final cList = <ProviderComment>[];
    if (j['comments'] is List) {
      for (final e in (j['comments'] as List)) {
        cList.add(ProviderComment.fromJson(e as Map<String, dynamic>));
      }
    }

    final imagesList = <String>[];
    if (j['extra_images'] is List) {
      for (final sublist in (j['extra_images'] as List)) {
        if (sublist is List) {
          imagesList.addAll(sublist.whereType<String>());
        }
      }
    }

    return ServiceProviderModel(
      id: (j['id'] as int?) ?? 0,
      fullName: (j['full_name'] ?? 'Unknown').toString(),
      phone: (j['phone'] ?? '').toString(),
      labourId: (j['labour_id'] as int?) ?? 0,
      labourName: (j['labour_name'] ?? 'غير محدد').toString(),
      cityId: j['city_id'] as int?,
      cityName: (j['city_name'] ?? '').toString(),
      regionId: j['region_id'] as int?,
      latitude: _toD(j['latitude']),
      longitude: _toD(j['longitude']),
      averageRating: _toD(j['averageRating']),
      personalImage: (j['personal_image'] ?? '').toString(),
      nationality: (j['nationality'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      comments: cList,
      rating: ProviderRating.fromJson(j['rating'] ?? {}),
      reviewsCount: _asInt(j['reviews_count']),
      serviceType: (j['service_type'] ?? '').toString(),
      extraImages: imagesList,
    );
  }
}