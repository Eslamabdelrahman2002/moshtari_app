class CarDetailsModel {
  final int id;
  final String title;
  final String description;
  final String? price;
  final String priceType;
  final List<String> imageUrls;
  final String createdAt;
  final String city;
  final String region;
  final String brand;
  final String modelAr;
  final String modelEn;
  final int year;
  final String condition;
  final String saleType;
  final String warranty;
  final String mileage;
  final String transmissionType;
  final int cylinderCount;
  final String color;
  final String fuelType;
  final String driveType;
  final String horsepower;
  final String doorCount;
  final String vehicleType;

  // بيانات المالك
  final int? userId;
  final String username;
  final String? userPhoneNumber;
  final String? profilePicture;

  final List<CommentModel> comments;
  final List<SimilarCarAdModel> similarAds;

  CarDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.priceType,
    required this.imageUrls,
    required this.createdAt,
    required this.city,
    required this.region,
    required this.brand,
    required this.modelAr,
    required this.modelEn,
    required this.year,
    required this.condition,
    required this.saleType,
    required this.warranty,
    required this.mileage,
    required this.transmissionType,
    required this.cylinderCount,
    required this.color,
    required this.fuelType,
    required this.driveType,
    required this.horsepower,
    required this.doorCount,
    required this.vehicleType,
    this.userId,
    required this.username,
    this.userPhoneNumber,
    this.profilePicture,
    this.comments = const [],
    this.similarAds = const [],
  });

  factory CarDetailsModel.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('Expected JSON object (Map), but got non-Map (maybe HTML error).');
    }

    final root = (json as Map).cast<String, dynamic>();
    final Map<String, dynamic> data =
    root['data'] is Map ? (root['data'] as Map).cast<String, dynamic>() : root;

    final userMap = (data['user'] as Map?)?.cast<String, dynamic>();

    return CarDetailsModel(
      id: (data['id'] as num?)?.toInt() ?? 0,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      price: data['price']?.toString(),
      priceType: data['price_type']?.toString() ?? '',
      imageUrls: (data['image_urls'] as List? ?? const []).map((e) => e.toString()).toList(),
      createdAt: data['created_at']?.toString() ?? '',
      city: (data['city'] as Map?)?['name']?.toString() ?? '',
      region: (data['region'] as Map?)?['name']?.toString() ?? '',
      brand: (data['brand'] as Map?)?['name']?.toString() ?? '',
      modelAr: (data['model'] as Map?)?['name_ar']?.toString() ?? '',
      modelEn: (data['model'] as Map?)?['name_en']?.toString() ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      condition: data['condition']?.toString() ?? '',
      saleType: data['sale_type']?.toString() ?? '',
      warranty: data['warranty']?.toString() ?? '',
      mileage: data['mileage']?.toString() ?? '',
      transmissionType: data['transmission_type']?.toString() ?? '',
      cylinderCount: (data['cylinder_count'] as num?)?.toInt() ?? 0,
      color: data['color']?.toString() ?? '',
      fuelType: data['fuel_type']?.toString() ?? '',
      driveType: data['drive_type']?.toString() ?? '',
      horsepower: data['horsepower']?.toString() ?? '',
      doorCount: data['door_count']?.toString() ?? '',
      vehicleType: data['vehicle_type']?.toString() ?? '',

      // مالك الإعلان
      userId: (userMap?['id'] as num?)?.toInt() ?? (data['user_id'] as num?)?.toInt(),
      username: userMap?['username']?.toString() ?? (data['username']?.toString() ?? ''),
      userPhoneNumber: userMap?['phone_number']?.toString(),
      profilePicture: userMap?['profile_picture_url']?.toString(),

      comments: (data['comments'] as List? ?? const []).map((c) {
        if (c is Map) {
          return CommentModel.fromJson(c.cast<String, dynamic>());
        } else if (c is String) {
          return CommentModel(userName: '', text: c);
        }
        return CommentModel(userName: '', text: '');
      }).toList(),
      similarAds: (data['similar_ads'] as List? ?? const [])
          .whereType<Map>()
          .map((s) => SimilarCarAdModel.fromJson(s.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class CommentModel {
  final String userName;
  final String text;

  CommentModel({required this.userName, required this.text});

  factory CommentModel.fromJson(dynamic json) {
    if (json is! Map) {
      return CommentModel(userName: '', text: json?.toString() ?? '');
    }
    final map = (json as Map).cast<String, dynamic>();
    return CommentModel(
      userName: (map['username'] ?? map['userName'] ?? map['user_name'] ?? '').toString(),
      text: (map['text'] ?? map['content'] ?? map['comment'] ?? map['comment_text'] ?? '').toString(),
    );
  }
}

class SimilarCarAdModel {
  final int id;
  final String title;
  final String? price;
  final int? year;
  final String? image;

  SimilarCarAdModel({
    required this.id,
    required this.title,
    this.price,
    this.year,
    this.image,
  });

  factory SimilarCarAdModel.fromJson(dynamic json) {
    if (json is! Map) {
      return SimilarCarAdModel(id: 0, title: '');
    }
    final map = (json as Map).cast<String, dynamic>();
    return SimilarCarAdModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      price: map['price']?.toString(),
      year: (map['year'] as num?)?.toInt(),
      image: map['image']?.toString(),
    );
  }
}