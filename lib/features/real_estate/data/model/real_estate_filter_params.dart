class RealEstateFilterParams {
  final String? realEstateType; // apartment | villa | land | office | building ...
  final String? purpose;        // sell | rent
  final double? priceMin;
  final double? priceMax;
  final int? areaMin;           // m2
  final int? areaMax;           // m2
  final int? roomsMin;
  final int? bathroomsMin;
  final int? cityId;
  final int? areaId;
  final String? sort;           // latest | price_asc | price_desc
  final int page;
  final int perPage;

  const RealEstateFilterParams({
    this.realEstateType,
    this.purpose,
    this.priceMin,
    this.priceMax,
    this.areaMin,
    this.areaMax,
    this.roomsMin,
    this.bathroomsMin,
    this.cityId,
    this.areaId,
    this.sort,
    this.page = 1,
    this.perPage = 20,
  });

  RealEstateFilterParams copyWith({
    String? realEstateType,
    String? purpose,
    double? priceMin,
    double? priceMax,
    int? areaMin,
    int? areaMax,
    int? roomsMin,
    int? bathroomsMin,
    int? cityId,
    int? areaId,
    String? sort,
    int? page,
    int? perPage,
  }) {
    return RealEstateFilterParams(
      realEstateType: realEstateType ?? this.realEstateType,
      purpose: purpose ?? this.purpose,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      areaMin: areaMin ?? this.areaMin,
      areaMax: areaMax ?? this.areaMax,
      roomsMin: roomsMin ?? this.roomsMin,
      bathroomsMin: bathroomsMin ?? this.bathroomsMin,
      cityId: cityId ?? this.cityId,
      areaId: areaId ?? this.areaId,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toJson() {
    final q = <String, dynamic>{
      if (realEstateType != null && realEstateType!.isNotEmpty) 'real_estate_type': realEstateType,
      if (purpose != null && purpose!.isNotEmpty) 'purpose': purpose,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (areaMin != null) 'area_m2_min': areaMin,
      if (areaMax != null) 'area_m2_max': areaMax,
      if (roomsMin != null) 'rooms_min': roomsMin,
      if (bathroomsMin != null) 'bathrooms_min': bathroomsMin,
      if (cityId != null) 'city_id': cityId,
      if (areaId != null) 'area_id': areaId,
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
      if (page > 1) 'page': page,
      if (perPage != 20) 'per_page': perPage,
    };
    q.removeWhere((k, v) => v == null || (v is String && v.isEmpty));
    return q;
  }
}