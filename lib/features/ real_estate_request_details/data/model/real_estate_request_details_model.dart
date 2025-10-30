// file: features/real_estate_requests/data/model/real_estate_request_details_model.dart

class RequestUserModel {
  final int? userId;
  final String? username;
  final String? phoneNumber;
  final String? profilePictureUrl;

  RequestUserModel({
    this.userId,
    this.username,
    this.phoneNumber,
    this.profilePictureUrl,
  });

  factory RequestUserModel.fromJson(Map<String, dynamic> json) {
    return RequestUserModel(
      userId: json['user_id'] as int?,
      username: json['username'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }
}

class RangeInt {
  final int? min;
  final int? max;

  RangeInt({this.min, this.max});

  factory RangeInt.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RangeInt();
    return RangeInt(
      min: json['min'] is int ? json['min'] as int : int.tryParse('${json['min']}'),
      max: json['max'] is int ? json['max'] as int : int.tryParse('${json['max']}'),
    );
  }

  @override
  String toString() {
    if (min == null && max == null) return 'N/A';
    if (min != null && max != null) return '$min - $max';
    return '${min ?? max}';
  }
}

class RangeString {
  final String? min;
  final String? max;

  RangeString({this.min, this.max});

  factory RangeString.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RangeString();
    return RangeString(
      min: json['min']?.toString(),
      max: json['max']?.toString(),
    );
  }

  @override
  String toString() {
    if ((min == null || min!.isEmpty) && (max == null || max!.isEmpty)) return 'N/A';
    if ((min?.isNotEmpty ?? false) && (max?.isNotEmpty ?? false)) return '$min - $max';
    return (min?.isNotEmpty ?? false) ? min! : (max ?? 'N/A');
  }
}

class RealEstateRequestSpecs {
  final String? realEstateType; // apartment | villa | ...
  final String? purpose; // rent | sell
  final RangeString? areaM2; // {min,max} كنص
  final RangeInt? streetWidth; // {min,max} أرقام
  final int? floorCount;
  final int? roomCount;
  final int? bathroomCount;
  final int? livingroomCount;
  final String? facade;
  final List<String>? services;
  final bool? isNegotiable;
  final String? notes;

  RealEstateRequestSpecs({
    this.realEstateType,
    this.purpose,
    this.areaM2,
    this.streetWidth,
    this.floorCount,
    this.roomCount,
    this.bathroomCount,
    this.livingroomCount,
    this.facade,
    this.services,
    this.isNegotiable,
    this.notes,
  });

  factory RealEstateRequestSpecs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RealEstateRequestSpecs();
    return RealEstateRequestSpecs(
      realEstateType: json['real_estate_type'] as String?,
      purpose: json['purpose'] as String?,
      areaM2: RangeString.fromJson(json['area_m2'] as Map<String, dynamic>?),
      streetWidth: RangeInt.fromJson(json['street_width'] as Map<String, dynamic>?),
      floorCount: json['floor_count'] as int?,
      roomCount: json['room_count'] as int?,
      bathroomCount: json['bathroom_count'] as int?,
      livingroomCount: json['livingroom_count'] as int?,
      facade: json['facade']?.toString(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      isNegotiable: json['is_negotiable'] as bool?,
      notes: json['notes']?.toString(),
    );
  }
}

class RealEstateRequestDetailsModel {
  final int id;
  final String? title;
  final String? price; // API راجع نص
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final bool allowComments;
  final bool allowMarketingOffers;
  final RequestUserModel? user;
  final String? city;
  final String? region;
  final RealEstateRequestSpecs? realEstateDetails;
  final List<dynamic> comments;
  final List<dynamic> similarAds; // مش هنستخدمها حالياً

  RealEstateRequestDetailsModel({
    required this.id,
    this.title,
    this.price,
    this.latitude,
    this.longitude,
    this.createdAt,
    required this.allowComments,
    required this.allowMarketingOffers,
    this.user,
    this.city,
    this.region,
    this.realEstateDetails,
    required this.comments,
    required this.similarAds,
  });

  factory RealEstateRequestDetailsModel.fromJson(Map<String, dynamic> json) {
    final created = json['created_at']?.toString();
    return RealEstateRequestDetailsModel(
      id: json['id'] as int,
      title: json['title']?.toString(),
      price: json['price']?.toString(),
      latitude: json['latitude'] == null ? null : double.tryParse('${json['latitude']}'),
      longitude: json['longitude'] == null ? null : double.tryParse('${json['longitude']}'),
      createdAt: created == null ? null : DateTime.tryParse(created),
      allowComments: json['allow_comments'] == true,
      allowMarketingOffers: json['allow_marketing_offers'] == true,
      user: json['user'] is Map<String, dynamic> ? RequestUserModel.fromJson(json['user']) : null,
      city: json['city']?.toString(),
      region: json['region']?.toString(),
      realEstateDetails: RealEstateRequestSpecs.fromJson(json['real_estate_details'] as Map<String, dynamic>?),
      comments: (json['comments'] as List<dynamic>? ?? const []),
      similarAds: (json['similarAds'] as List<dynamic>? ?? const []),
    );
  }
}