class AdsFilter {
  // البحث النصي (يُستخدم في /users/search فقط)
  final String? query;

  // الفلترة العامة (يُستخدم في /users/home)
  final double? priceMin;
  final double? priceMax;
  final String? condition;     // new | used
  final String? advertiseType; // auction | bargain | fixed
  final bool? hasImages;       // صور فقط
  final String? sort;          // latest | nearest (اختياري)
  final int? distanceKm;       // (اختياري)
  final double? lat;           // (اختياري)
  final double? lng;           // (اختياري)
  final String? vehicleType;   // عام لو أردت
  final String? fuelType;      // عام لو أردت
  final int? year;             // عام لو أردت

  final int? categoryId;
  final int page;
  final int perPage;

  const AdsFilter({
    this.query,
    this.priceMin,
    this.priceMax,
    this.condition,
    this.advertiseType,
    this.hasImages,
    this.sort,
    this.distanceKm,
    this.lat,
    this.lng,
    this.vehicleType,
    this.fuelType,
    this.year,
    this.categoryId,
    this.page = 1,
    this.perPage = 20,
  });

  AdsFilter copyWith({
    String? query,
    double? priceMin,
    double? priceMax,
    String? condition,
    String? advertiseType,
    bool? hasImages,
    String? sort,
    int? distanceKm,
    double? lat,
    double? lng,
    String? vehicleType,
    String? fuelType,
    int? year,
    int? categoryId,
    int? page,
    int? perPage,
  }) {
    return AdsFilter(
      query: query ?? this.query,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      condition: condition ?? this.condition,
      advertiseType: advertiseType ?? this.advertiseType,
      hasImages: hasImages ?? this.hasImages,
      sort: sort ?? this.sort,
      distanceKm: distanceKm ?? this.distanceKm,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      vehicleType: vehicleType ?? this.vehicleType,
      fuelType: fuelType ?? this.fuelType,
      year: year ?? this.year,
      categoryId: categoryId ?? this.categoryId,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  // /users/search?query=...
  Map<String, dynamic> toSearchQuery() {
    final q = <String, dynamic>{
      if (query != null && query!.trim().isNotEmpty) 'query': query!.trim(),
      if (page > 1) 'page': page,
      if (perPage != 20) 'per_page': perPage,
    };
    q.removeWhere((k, v) => v == null || (v is String && v.isEmpty));
    return q;
  }

  // /users/home?price_min=... (أرسل فقط ما يدعمه الـ API لديك)
  Map<String, dynamic> toHomeFilterQuery() {
    final q = <String, dynamic>{
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (condition != null) 'condition': condition,
      if (advertiseType != null) 'advertise_type': advertiseType,
      if (hasImages == true) 'has_images': true,
      if (sort != null) 'sort': sort,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (fuelType != null) 'fuel_type': fuelType,
      if (year != null) 'year': year,
      if (categoryId != null) 'category_id': categoryId,
      if (page > 1) 'page': page,
      if (perPage != 20) 'per_page': perPage,
    };
    q.removeWhere((k, v) => v == null || (v is String && v.isEmpty));
    return q;
  }
}