class RealEstateListingsFilter {
  // required: ad | request
  final String type;

  // optional (حسب وثيقة Postman في الصورة)
  final String? requestType;    // buy | rent   (للطلبات)
  final String? realEstateType; // apartment | villa | land | office ...
  final String? paymentMethod;  // cash | installment (إن لزم)
  final int? cityId;
  final double? minBudget;
  final double? maxBudget;
  final String? sortBy;         // latest | price_asc | price_desc
  final int page;
  final int perPage;

  const RealEstateListingsFilter({
    required this.type,
    this.requestType,
    this.realEstateType,
    this.paymentMethod,
    this.cityId,
    this.minBudget,
    this.maxBudget,
    this.sortBy,
    this.page = 1,
    this.perPage = 20,
  });

  RealEstateListingsFilter copyWith({
    String? type,
    String? requestType,
    String? realEstateType,
    String? paymentMethod,
    int? cityId,
    double? minBudget,
    double? maxBudget,
    String? sortBy,
    int? page,
    int? perPage,
  }) {
    return RealEstateListingsFilter(
      type: type ?? this.type,
      requestType: requestType ?? this.requestType,
      realEstateType: realEstateType ?? this.realEstateType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cityId: cityId ?? this.cityId,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{
      'type': type,
      if (requestType != null && requestType!.isNotEmpty) 'request_type': requestType,
      if (realEstateType != null && realEstateType!.isNotEmpty) 'real_estate_type': realEstateType,
      if (paymentMethod != null && paymentMethod!.isNotEmpty) 'payment_method': paymentMethod,
      if (cityId != null) 'city_id': cityId,
      if (minBudget != null) 'min_budget': minBudget,
      if (maxBudget != null) 'max_budget': maxBudget,
      if (sortBy != null && sortBy!.isNotEmpty) 'sort_by': sortBy,
      if (page > 1) 'page': page,
      if (perPage != 20) 'per_page': perPage,
    };
    q.removeWhere((k, v) => v == null || (v is String && v.isEmpty));
    return q;
  }
}